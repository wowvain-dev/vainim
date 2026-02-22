-- ============================================================
-- COLORSCHEMES
-- All themes load at startup (lazy=false) so the picker can
-- switch between them instantly. Active theme is persisted in
-- stdpath("data")/vainim_theme — edit with <leader>ut.
-- ============================================================

return {
  -- ── Catppuccin ─────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha",
      transparent_background = true,   -- use terminal background
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = { enabled = false },
      integrations = {
        blink_cmp = true,
        bufferline = true,
        cmp = true,
        flash = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        neo_tree = true,
        noice = true,
        notify = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },

  -- ── Tokyo Night ────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      style = "storm",
      transparent = true,              -- use terminal background
      terminal_colors = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
    end,
  },

  -- ── Gruvbox ────────────────────────────────────────────────
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      contrast = "hard",
      transparent_mode = true,         -- use terminal background
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
    end,
  },

  -- ── Rose Pine ──────────────────────────────────────────────
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    opts = {
      variant = "moon",
      disable_background = true,       -- use terminal background
      disable_float_background = true,
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
    end,
  },

  -- ── Kanagawa ───────────────────────────────────────────────
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      theme = "wave",
      transparent = true,              -- use terminal background
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
    end,
  },
}
