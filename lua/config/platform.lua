-- ============================================================
-- Platform detection
-- ============================================================

local M = {}

--- True when running on NixOS (detected by /etc/NIXOS sentinel file).
M.is_nixos = (function()
  local f = io.open("/etc/NIXOS", "r")
  if f then
    f:close()
    return true
  end
  return false
end)()

return M
