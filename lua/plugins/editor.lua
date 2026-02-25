-- ============================================================
-- Editor Enhancements: which-key, comments, pairs, surround,
--                      flash, trouble, colorizer, mini
-- ============================================================

return {
  -- ── Which-key: discover keybindings ───────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      icons = {
        breadcrumb = "»",
        separator  = "➜",
        group      = "+",
        ellipsis   = "…",
        mappings   = true,
        rules      = {},
        colors     = true,
        keys       = {},
      },
      win = {
        border = "rounded",
        wo = { winblend = 0 },
      },
      layout = {
        width = { min = 20 },
        spacing = 3,
      },
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- Register group prefixes for cleaner which-key menu
      wk.add({
        { "<leader>b",  group = "buffers" },
        { "<leader>c",  group = "code / LSP" },
        { "<leader>d",  group = "debug" },
        { "<leader>e",  group = "explorer" },
        { "<leader>f",  group = "find / files" },
        { "<leader>g",  group = "git" },
        { "<leader>h",  group = "git hunks" },
        { "<leader>l",  group = "LSP" },
        { "<leader>n",  group = "swap next" },
        { "<leader>p",  group = "peek / swap prev" },
        { "<leader>r",  group = "rename" },
        { "<leader>s",  group = "split" },
        { "<leader>t",  group = "terminal / tab" },
        { "<leader>T",  group = "tests" },
        { "<leader>u",  group = "toggle / ui" },
        { "<leader>w",  group = "workspace" },
        { "<leader>x",  group = "trouble / diagnostics" },
        { "g",          group = "goto" },
        { "]",          group = "next" },
        { "[",          group = "prev" },
      })
    end,
  },

  -- ── Comment.nvim: smart commenting ────────────────────────
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        mappings = {
          basic  = true,
          extra  = true,
        },
      })
    end,
  },

  -- ── nvim-autopairs: smart bracket pairing ─────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua  = { "string" },
        javascript = { "template_string" },
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map           = "<M-e>",
        chars         = { "{", "[", "(", '"', "'" },
        pattern       = [=[[%'%"%>%]%)%}%,]]=],
        end_key       = "$",
        before_key    = "p",
        after_key     = "n",
        cursor_pos_before = true,
        keys          = "qwertyuiopzxcvbnmasdfghjkl",
        manual_position = true,
        highlight     = "Search",
        highlight_grey = "Comment",
      },
    },
  },

  -- ── nvim-surround: add/change/delete surroundings ─────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- Default bindings:
    --   ys{motion}{char}  → add surround
    --   cs{old}{new}      → change surround
    --   ds{char}          → delete surround
  },

  -- ── Flash: fast motion / search navigation ────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = true },
        char   = { enabled = true, jump_labels = true },
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Flash remote" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
      { "<C-s>", mode = { "c" },           function() require("flash").toggle() end,             desc = "Flash toggle in search" },
    },
  },

  -- ── Trouble: beautiful diagnostics list ───────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                    desc = "Workspace diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",       desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",            desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>",                        desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>",                         desc = "Quickfix list" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "Prev trouble/quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
    opts = {
      modes = {
        preview_float = {
          mode = "diagnostics",
          preview = {
            type = "float",
            relative = "editor",
            border = "rounded",
            title = "Diagnostics",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.4, height = 0.4 },
            zindex = 200,
          },
        },
      },
    },
  },

  -- ── nvim-colorizer: highlight color codes in-line ─────────
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "scss", "less", "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "lua", "vim", "yaml", "toml" },
    opts = {
      filetypes = {
        css     = { css = true },
        scss    = { css = true },
        less    = { css = true },
        html    = { css = true },
        javascript  = { css = true },
        javascriptreact = { css = true },
        typescript = { css = true },
        typescriptreact = { css = true },
        json   = { css = true },
        jsonc  = { css = true },
        lua    = { css = true },
        vim    = { css = true },
        yaml   = { css = true },
        toml   = { css = true },
      },
      user_default_options = {
        RGB      = true,
        RRGGBB   = true,
        names    = true,
        RRGGBBAA = true,
        rgb_fn   = false,
        hsl_fn   = false,
        css      = false,
        css_fn   = false,
        mode     = "background",
        tailwind = false,
        always_update = false,
      },
    },
  },

  -- ── inc-rename: live preview while renaming ───────────────
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>rn",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename (inc-rename)",
      },
    },
    opts = {},
  },
}
