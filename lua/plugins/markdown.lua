-- ============================================================
-- Markdown Rendering — markview.nvim
-- ============================================================

local PRESET_PROFILES = {
  catppuccin = { headings = "glow", horizontal_rules = "arrowed", tables = "rounded" },
  tokyonight = { headings = "simple", horizontal_rules = "dashed", tables = "single" },
  rose = { headings = "glow_center", horizontal_rules = "dotted", tables = "rounded" },
  kanagawa = { headings = "slanted", horizontal_rules = "thick", tables = "double" },
  gruvbox = { headings = "marker", horizontal_rules = "solid", tables = "rounded" },
  light = { headings = "simple", horizontal_rules = "thin", tables = "single" },
  dark = { headings = "arrowed", horizontal_rules = "solid", tables = "rounded" },
}

local function theme_profile()
  local cs = (vim.g.colors_name or ""):lower()
  for key, preset in pairs(PRESET_PROFILES) do
    if key ~= "light" and key ~= "dark" and cs:find(key, 1, true) then
      return preset
    end
  end
  return vim.o.background == "light" and PRESET_PROFILES.light or PRESET_PROFILES.dark
end

local function sync_markview_blending()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = type(normal.bg) == "number" and string.format("#%06x", normal.bg)

  if vim.o.background == "dark" then
    vim.g.markview_dark_bg = bg or "#1e1e2e"
    vim.g.markview_alpha = 0.16
  else
    vim.g.markview_light_bg = bg or "#eff1f5"
    vim.g.markview_alpha = 0.18
  end
end

local function markview_opts()
  local presets = require("markview.presets")
  local profile = theme_profile()
  return {
    preview = {
      enable = false,
      enable_hybrid_mode = false,
      icon_provider = "devicons",
      map_gx = true,
    },
    markdown = {
      headings = presets.headings[profile.headings],
      horizontal_rules = presets.horizontal_rules[profile.horizontal_rules],
      tables = presets.tables[profile.tables],
      block_quotes = {
        default = {
          border = "▏",
          hl = "MarkviewBlockQuoteDefault",
        },
      },
    },
  }
end

local function setup_markview()
  sync_markview_blending()
  require("markview").setup(markview_opts())
end

local function has_glow_binary()
  return vim.fn.executable("glow") == 1
end

local function run_glow(close)
  if not has_glow_binary() then
    vim.notify("glow binary not found in PATH. Install it to use markdown preview.", vim.log.levels.WARN)
    return
  end
  vim.cmd(close and "Glow!" or "Glow")
end

return {
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    ft = { "markdown", "md" },
    config = function()
      setup_markview()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("vainim_markview", { clear = true }),
        callback = setup_markview,
      })
    end,
    keys = {
      { "<leader>um", "<cmd>Markview toggle<CR>",      desc = "Enable markdown render (markview)" },
      { "<leader>uM", "<cmd>Markview splitToggle<CR>", desc = "Toggle markview split render" },
    },
  },
  {
    "ellisonleao/glow.nvim",
    ft = { "markdown", "md" },
    cmd = "Glow",
    opts = {
      border = "rounded",
      pager = false,
      width_ratio = 0.9,
      height_ratio = 0.9,
    },
    keys = {
      {
        "<leader>ug",
        function() run_glow(false) end,
        desc = "Preview markdown with glow",
      },
      {
        "<leader>uG",
        function() run_glow(true) end,
        desc = "Close glow preview",
      },
    },
  },
}
