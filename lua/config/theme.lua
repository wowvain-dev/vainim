-- ============================================================
-- Theme Persistence
-- Stores the active colorscheme name in stdpath("data")/vainim_theme
-- so it survives restarts. Used by theme_picker.lua and init.lua.
-- ============================================================

local M = {}

M.default = "catppuccin-mocha"

local state_file = vim.fn.stdpath("data") .. "/vainim_theme"

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
  local ok = pcall(vim.cmd.colorscheme, cs)
  if ok then
    M.save(cs)
    return true
  end
  -- Saved theme unavailable (e.g. plugin not yet installed) — use default
  if cs ~= M.default then
    pcall(vim.cmd.colorscheme, M.default)
    M.save(M.default)
  end
  return false
end

return M
