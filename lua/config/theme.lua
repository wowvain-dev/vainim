-- ============================================================
-- Theme Persistence
-- Stores the active colorscheme name in stdpath("data")/vainim_theme
-- so it survives restarts. Used by theme_picker.lua and init.lua.
-- ============================================================

local M = {}

M.default = "catppuccin-mocha"

local state_file = vim.fn.stdpath("data") .. "/vainim_theme"
local theme_to_plugin = {
  ["catppuccin-mocha"] = "catppuccin",
  ["catppuccin-macchiato"] = "catppuccin",
  ["catppuccin-frappe"] = "catppuccin",
  ["catppuccin-latte"] = "catppuccin",
  ["tokyonight-storm"] = "tokyonight.nvim",
  ["tokyonight-moon"] = "tokyonight.nvim",
  ["tokyonight-night"] = "tokyonight.nvim",
  ["gruvbox"] = "gruvbox.nvim",
  ["rose-pine-moon"] = "rose-pine",
  ["rose-pine-main"] = "rose-pine",
  ["rose-pine-dawn"] = "rose-pine",
  ["kanagawa-wave"] = "kanagawa.nvim",
  ["kanagawa-dragon"] = "kanagawa.nvim",
  ["kanagawa-lotus"] = "kanagawa.nvim",
}

local function ensure_theme_plugin(cs)
  local plugin_name = theme_to_plugin[cs]
  if not plugin_name then
    return
  end
  pcall(require("lazy").load, {
    plugins = { plugin_name },
    wait = true,
  })
end

---Read the saved colorscheme name (or return the default).
function M.get()
  local f = io.open(state_file, "r")
  if f then
    local cs = vim.trim(f:read("*a"))
    f:close()
    if cs ~= "" then return cs end
  end
  return M.default
end

---Persist a colorscheme name to disk.
function M.save(cs)
  local f = io.open(state_file, "w")
  if f then
    f:write(cs)
    f:close()
  end
end

---Apply a colorscheme (and save it). Falls back to default on failure.
---@param cs? string colorscheme name; omit to use the saved one
function M.apply(cs)
  cs = cs or M.get()
  ensure_theme_plugin(cs)
  local ok = pcall(vim.cmd.colorscheme, cs)
  if ok then
    M.save(cs)
    return true
  end
  -- Saved theme unavailable (e.g. plugin not yet installed) — use default
  if cs ~= M.default then
    ensure_theme_plugin(M.default)
    pcall(vim.cmd.colorscheme, M.default)
    M.save(M.default)
  end
  return false
end

---Ensure colorscheme plugin is loaded before `:colorscheme`.
---@param cs string
function M.ensure_loaded(cs)
  ensure_theme_plugin(cs)
end

---Preview a colorscheme (no persistence).
---@param cs string
function M.preview(cs)
  ensure_theme_plugin(cs)
  pcall(vim.cmd.colorscheme, cs)
end

return M
