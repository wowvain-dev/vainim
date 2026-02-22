-- ============================================================
-- Theme Picker — floating window with live preview
-- Open with <leader>ut
-- ============================================================

local M   = {}
local thm = require("config.theme")

local WIN_W = 44  -- buffer content width (borders are outside this)

-- ── Theme catalogue ──────────────────────────────────────────
-- false entries render as a separator line
local catalogue = {
  { cs = "catppuccin-mocha",     label = "Catppuccin Mocha",     bg = "dark",  icon = "󰄛" },
  { cs = "catppuccin-macchiato", label = "Catppuccin Macchiato", bg = "dark",  icon = "󰄛" },
  { cs = "catppuccin-frappe",    label = "Catppuccin Frappé",    bg = "dark",  icon = "󰄛" },
  { cs = "catppuccin-latte",     label = "Catppuccin Latte",     bg = "light", icon = "󰄛" },
  false,
  { cs = "tokyonight-storm",     label = "Tokyo Night Storm",    bg = "dark",  icon = "" },
  { cs = "tokyonight-moon",      label = "Tokyo Night Moon",     bg = "dark",  icon = "" },
  { cs = "tokyonight-night",     label = "Tokyo Night Night",    bg = "dark",  icon = "" },
  false,
  { cs = "gruvbox",              label = "Gruvbox",              bg = "dark",  icon = "" },
  false,
  { cs = "rose-pine-moon",       label = "Rose Pine Moon",       bg = "dark",  icon = "" },
  { cs = "rose-pine-main",       label = "Rose Pine",            bg = "dark",  icon = "" },
  { cs = "rose-pine-dawn",       label = "Rose Pine Dawn",       bg = "light", icon = "" },
  false,
  { cs = "kanagawa-wave",        label = "Kanagawa Wave",        bg = "dark",  icon = "" },
  { cs = "kanagawa-dragon",      label = "Kanagawa Dragon",      bg = "dark",  icon = "" },
  { cs = "kanagawa-lotus",       label = "Kanagawa Lotus",       bg = "light", icon = "" },
}

-- ── Line renderers ────────────────────────────────────────────
local function entry_line(entry, saved_cs)
  local mark   = entry.cs == saved_cs and ">" or " "
  local badge  = entry.bg == "dark" and " dark " or "light "
  local left   = "  " .. mark .. "  " .. entry.icon .. " " .. entry.label
  -- Use strdisplaywidth so nerd-font icons count as 1 cell, not multiple bytes
  local pad    = math.max(1, WIN_W - vim.fn.strdisplaywidth(left) - #badge)
  return left .. string.rep(" ", pad) .. badge
end

local function sep_line()
  return "  " .. string.rep("─", WIN_W - 4) .. "  "
end

-- ── Build buffer lines ────────────────────────────────────────
-- Returns (lines, row_to_cat) where row_to_cat[r] is either a
-- catalogue index (entry) or false (separator).
local function build(saved_cs)
  local lines, rtc = {}, {}
  for i, item in ipairs(catalogue) do
    local r    = #lines + 1
    lines[r]   = item == false and sep_line() or entry_line(item, saved_cs)
    rtc[r]     = item ~= false and i or false
  end
  return lines, rtc
end

-- ── Navigation helpers ────────────────────────────────────────
local function first_row(rtc, total)
  for r = 1, total do if rtc[r] then return r end end
  return 1
end
local function last_row(rtc, total)
  for r = total, 1, -1 do if rtc[r] then return r end end
  return total
end
local function next_row(r, rtc, total)
  for i = r + 1, total do if rtc[i] then return i end end
  return r
end
local function prev_row(r, rtc)
  for i = r - 1, 1, -1 do if rtc[i] then return i end end
  return r
end

-- ── Open the picker ───────────────────────────────────────────
function M.open()
  local saved_cs    = thm.get()
  local original_cs = vim.g.colors_name or saved_cs
  local current_cs  = original_cs

  local lines, rtc = build(saved_cs)
  local total      = #lines

  -- Find the row that marks the saved theme
  local start_row = first_row(rtc, total)
  for r = 1, total do
    local ci = rtc[r]
    if ci and catalogue[ci].cs == saved_cs then
      start_row = r; break
    end
  end

  -- ── Buffer ───────────────────────────────────────────────────
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden  = "wipe"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Dim separator rows
  local ns = vim.api.nvim_create_namespace("vainim_picker")
  for r = 1, total do
    if not rtc[r] then
      vim.api.nvim_buf_add_highlight(buf, ns, "Comment", r - 1, 0, -1)
    end
  end

  -- ── Window ───────────────────────────────────────────────────
  local ui  = vim.api.nvim_list_uis()[1]
  local win = vim.api.nvim_open_win(buf, true, {
    relative   = "editor",
    width      = WIN_W,
    height     = total,
    col        = math.floor((ui.width  - WIN_W) / 2),
    row        = math.floor((ui.height - total) / 2),
    style      = "minimal",
    border     = "rounded",
    title      = "  󰏘 Theme Picker  ",
    title_pos  = "center",
    footer     = "  ↵ apply  q cancel  ",
    footer_pos = "center",
  })

  vim.wo[win].cursorline   = true
  vim.wo[win].wrap         = false
  vim.wo[win].signcolumn   = "no"
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual"
  vim.api.nvim_win_set_cursor(win, { start_row, 0 })

  -- ── Live preview ──────────────────────────────────────────────
  local function preview()
    if not vim.api.nvim_win_is_valid(win) then return end
    local ci = rtc[vim.api.nvim_win_get_cursor(win)[1]]
    if not ci then return end
    local cs = catalogue[ci].cs
    if cs ~= current_cs then
      current_cs = cs
      pcall(vim.cmd.colorscheme, cs)
    end
  end

  vim.api.nvim_create_autocmd("CursorMoved", { buffer = buf, callback = preview })

  -- ── Confirm ───────────────────────────────────────────────────
  local closed = false
  local function confirm()
    if closed then return end
    closed = true
    local ci = rtc[vim.api.nvim_win_get_cursor(win)[1]]
    if not ci then closed = false; return end  -- on a separator
    local entry = catalogue[ci]
    vim.api.nvim_win_close(win, true)
    pcall(vim.cmd.colorscheme, entry.cs)
    thm.save(entry.cs)
    vim.notify(
      "Theme → " .. entry.label,
      vim.log.levels.INFO,
      { title = "󰏘 Theme Picker", timeout = 2500 }
    )
  end

  -- ── Cancel / restore ──────────────────────────────────────────
  local function cancel()
    if closed then return end
    closed = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if current_cs ~= original_cs then
      pcall(vim.cmd.colorscheme, original_cs)
    end
  end

  -- ── Keymaps ───────────────────────────────────────────────────
  local o = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set("n", "<CR>",  confirm, o)
  vim.keymap.set("n", "q",     cancel,  o)
  vim.keymap.set("n", "<Esc>", cancel,  o)

  -- Navigation factory: move cursor then preview
  local function nav(get_nr)
    return function()
      if not vim.api.nvim_win_is_valid(win) then return end
      local r  = vim.api.nvim_win_get_cursor(win)[1]
      local nr = get_nr(r)
      if nr ~= r then
        vim.api.nvim_win_set_cursor(win, { nr, 0 })
        preview()
      end
    end
  end

  local dn = nav(function(r) return next_row(r, rtc, total) end)
  local up = nav(function(r) return prev_row(r, rtc) end)

  vim.keymap.set("n", "j",      dn, o)
  vim.keymap.set("n", "<Down>", dn, o)
  vim.keymap.set("n", "k",      up, o)
  vim.keymap.set("n", "<Up>",   up, o)
  vim.keymap.set("n", "gg", nav(function() return first_row(rtc, total) end), o)
  vim.keymap.set("n", "G",  nav(function() return last_row(rtc, total)  end), o)

  -- Cancel if the user leaves by other means (e.g. <C-w>w)
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    buffer   = buf,
    once     = true,
    callback = cancel,
  })
end

return M
