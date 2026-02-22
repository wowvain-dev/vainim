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

    -- Groups that should always show the terminal background
    local bg_none = {
      -- Editor panes
      "Normal", "NormalNC",
      "SignColumn", "LineNr", "CursorLineNr", "RelativeNumber",
      "EndOfBuffer", "FoldColumn",
      -- Separators (these were causing the slant-separator artifacts)
      "VertSplit", "WinSeparator",
      -- Float BORDERS only — keep NormalFloat with a bg so popups stay readable
      "FloatBorder", "FloatTitle", "FloatFooter",
      -- nvim-tree
      "NvimTreeNormal", "NvimTreeNormalFloat",
      "NvimTreeEndOfBuffer", "NvimTreeWinSeparator",
      -- Plugin borders (which-key popup border, etc.)
      "WhichKeyBorder", "WhichKeyNormal",
      "TelescopeBorder",
      "NoiceCmdlinePopupBorder", "NoicePopupBorder",
      "LazyNormal",
      "MasonNormal",
    }
    for _, g in ipairs(bg_none) do
      -- Merge: preserve any existing fg/sp, only clear bg
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = g, link = false })
      if ok then
        hl.bg      = nil
        hl.ctermbg = nil
        vim.api.nvim_set_hl(0, g, hl)
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
