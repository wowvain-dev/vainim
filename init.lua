-- ============================================================
-- VAINIM — Neovim Config Entry Point
-- ============================================================

-- Space is the leader key — must be set before lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Faster Lua module loading for startup and hot reloads (requires 0.9+)
if vim.loader and vim.loader.enable then
  vim.loader.enable()
end

-- Core settings (no plugin dependencies)
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap lazy.nvim (auto-installs on first run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Transparent background: set before lazy so the ColorScheme autocmd
-- (defined in autocmds.lua) has the flag ready when the theme applies.
vim.g.vainim_transparent = true

-- Load all plugin specs from lua/plugins/
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    colorscheme = { "catppuccin", "habamax" },
  },
  checker = {
    -- Background update checks have caused sporadic long-idle instability on
    -- some Windows setups; keep them off there.
    enabled = vim.fn.has("win32") == 0,
    notify = false, -- silently check for updates
  },
  change_detection = {
    notify = false,
  },
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Restore the persisted colorscheme.
require("config.theme").apply()

-- Pre-load Telescope shortly after startup so first <leader>ff feels instant
-- without adding to first-frame startup cost.
vim.defer_fn(function()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return end
  pcall(lazy.load, { plugins = { "telescope.nvim" }, wait = true })
  local ok_telescope, telescope = pcall(require, "telescope")
  if ok_telescope then
    pcall(telescope.load_extension, "fzf")
  end
end, 250)
