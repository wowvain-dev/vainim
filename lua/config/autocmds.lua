-- ============================================================
-- Autocommands
-- ============================================================

local function augroup(name)
  return vim.api.nvim_create_augroup("vainim_" .. name, { clear = true })
end
local au = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
au("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Restore cursor to last position on file open
au("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when terminal window resizes
au("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Close certain filetypes with <q>
au("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "lspinfo", "man", "notify", "qf",
    "spectre_panel", "startuptime", "tsplayground",
    "PlenaryTestPopup", "checkhealth",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Wrap + spell in prose filetypes
au("FileType", {
  group = augroup("prose"),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Remove trailing whitespace on save (except for certain filetypes)
au("BufWritePre", {
  group = augroup("trim_whitespace"),
  pattern = "*",
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local skip = { "markdown", "text" }
    for _, f in ipairs(skip) do
      if ft == f then return end
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
})

-- Enable tree-sitter folds only for files that are not too large.
local function set_buffer_folds(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local max_filesize = 150 * 1024 -- 150 KB
  local stat = vim.api.nvim_buf_get_name(buf) ~= "" and vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  local use_treesitter = false
  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype

  -- Avoid ephemeral/no-file buffers that can error when applying fold settings.
  if bt ~= "" or ft == "" then
    return
  end

  if not (stat and stat.size > max_filesize) and ft ~= "TelescopePrompt" and ft ~= "notify" then
    local ok, has_parser = pcall(vim.treesitter.language.get_lang, ft)
    use_treesitter = ok and has_parser
  end

  local set_any = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      set_any = true
      local ok, err = pcall(function()
        vim.wo[win].foldmethod = use_treesitter and "expr" or "manual"
        vim.wo[win].foldexpr = use_treesitter and "v:lua.vim.treesitter.foldexpr()" or ""
      end)
      if not ok then
        vim.notify("Could not apply fold settings for window " .. win .. ": " .. err, vim.log.levels.DEBUG)
      end
    end
  end

  if not set_any then
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      local ok, err = pcall(function()
        vim.wo[win].foldmethod = use_treesitter and "expr" or "manual"
        vim.wo[win].foldexpr = use_treesitter and "v:lua.vim.treesitter.foldexpr()" or ""
      end)
      if not ok then
        vim.notify("Could not apply fold settings for current window: " .. err, vim.log.levels.DEBUG)
      end
    end
  end
end

au("BufReadPost", {
  group = augroup("treesitter_folds"),
  callback = function(ev)
    set_buffer_folds(ev.buf)
  end,
})
au("FileType", {
  group = augroup("treesitter_folds"),
  callback = function(ev)
    set_buffer_folds(ev.buf)
  end,
})

-- Strip stray CRs in LF files on save (avoids visible ^M artifacts)
au("BufWritePre", {
  group = augroup("strip_cr"),
  pattern = "*",
  callback = function(ev)
    if vim.bo[ev.buf].binary or vim.bo[ev.buf].buftype ~= "" then return end
    if vim.bo[ev.buf].fileformat ~= "unix" then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\r$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
})

-- Auto-create parent directories on save
au("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Transparent background: reapply after every colorscheme change so
-- the theme's own background colours are stripped out, leaving the
-- terminal's native background visible.
au("ColorScheme", {
  group = augroup("transparent_bg"),
  pattern = "*",
  callback = function()
    if not vim.g.vainim_transparent then return end

    local function clear_bg(group)
      -- Preserve fg/style and only remove the background layer.
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
      if not ok or type(hl) ~= "table" then return end
      hl.bg = nil
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end

    -- Groups that should always show the terminal background
    local bg_none = {
      -- Editor panes
      "Normal", "NormalNC",
      "SignColumn", "LineNr", "CursorLineNr", "RelativeNumber",
      "EndOfBuffer", "FoldColumn",
      -- Separators (these were causing the slant-separator artifacts)
      "VertSplit", "WinSeparator",
      -- Float windows (body + borders) for full transparent popups
      "NormalFloat", "NormalFloatNC",
      "FloatBorder", "FloatTitle", "FloatFooter",
      "FloatShadow", "FloatShadowThrough",
      -- Popup-menu body (keep selection groups styled)
      "Pmenu", "PmenuKind", "PmenuExtra", "PmenuMatch",
      -- nvim-tree
      "NvimTreeNormal", "NvimTreeNormalFloat",
      "NvimTreeEndOfBuffer", "NvimTreeWinSeparator",
      -- Plugin borders (which-key popup border, etc.)
      "WhichKey", "WhichKeyBorder", "WhichKeyNormal",
      "TelescopeBorder",
      "NoiceCmdlinePopupBorder", "NoicePopupBorder",
      "LazyNormal",
      "MasonNormal",
    }
    for _, g in ipairs(bg_none) do
      clear_bg(g)
    end

    -- which-key may define additional highlight groups in newer versions
    -- (e.g. keycaps/icons). Clear all of them to avoid opaque patches.
    for _, g in ipairs(vim.fn.getcompletion("", "highlight")) do
      if g:find("^WhichKey") then
        clear_bg(g)
      end
    end
  end,
})

-- Detect shebang and set filetype for new files
au("BufNewFile", {
  group = augroup("shebang"),
  pattern = "*",
  callback = function()
    vim.schedule(function()
      vim.cmd("filetype detect")
    end)
  end,
})

-- Windows Terminal can occasionally keep input-related terminal modes enabled
-- after long-running TUIs or abrupt exits. Reset the terminal state early in
-- the shutdown sequence so the shell prompt does not render on a stale frame.
local function reset_windows_terminal_state()
  if vim.fn.has("win32") == 0 or not os.getenv("WT_SESSION") then return end
  if vim.g.vainim_terminal_state_reset_done then return end

  local reset = table.concat({
    "\27[0m",      -- clear text attributes
    "\27[?25h",    -- ensure cursor is visible
    "\27[?1l",     -- normal cursor keys mode
    "\27>",        -- normal keypad mode
    "\27[?1000l",  -- disable mouse tracking
    "\27[?1002l",
    "\27[?1003l",
    "\27[?1004l",
    "\27[?1005l",
    "\27[?1006l",
    "\27[?1015l",
    "\27[?2004l",  -- disable bracketed paste
    "\27[>4;0m",   -- disable modifyOtherKeys
    "\27[?1049l",  -- leave alternate screen if still enabled
    "\27[?1047l",  -- leave legacy alternate screen
    "\27[?47l",    -- leave legacy alternate screen
  })

  pcall(function()
    io.stdout:write(reset)
    io.stdout:flush()
    vim.g.vainim_terminal_state_reset_done = true
  end)
end

au({ "VimLeavePre", "ExitPre" }, {
  group = augroup("terminal_state_reset"),
  callback = reset_windows_terminal_state,
})

-- Mason registers a VimLeavePre terminator hook that can occasionally stall
-- terminal handoff on Windows Terminal. Keep Mason enabled, but remove only
-- that specific quit hook on this platform.
local function prune_windows_quit_hooks()
  if vim.fn.has("win32") == 0 or not os.getenv("WT_SESSION") then return end

  for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "VimLeavePre" })) do
    if type(ac.callback) == "function" then
      local ok, info = pcall(debug.getinfo, ac.callback, "S")
      local src = (ok and info and info.source) or ""
      if src:find("mason.nvim/lua/mason/init.lua", 1, true) then
        pcall(vim.api.nvim_del_autocmd, ac.id)
      end
    end
  end
end

prune_windows_quit_hooks()
vim.defer_fn(prune_windows_quit_hooks, 800)
au("User", {
  group = augroup("windows_exit_hooks"),
  pattern = "VeryLazy",
  callback = prune_windows_quit_hooks,
})
