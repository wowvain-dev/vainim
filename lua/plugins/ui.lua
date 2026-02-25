-- ============================================================
-- UI Plugins: statusline, bufferline, notifications, dashboard,
--             indent guides, todo highlighting
-- ============================================================

return {
  -- ── Lualine — statusline ───────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          { "encoding" },
          { "fileformat" },
          { "filetype", icon_only = false },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "nvim-tree", "lazy", "trouble", "toggleterm" },
    },
  },

  -- ── Bufferline — tab-style buffer bar ─────────────────────
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",         desc = "Toggle buffer pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned buffers" },
      { "[b",         "<cmd>BufferLineCyclePrev<CR>",         desc = "Prev buffer" },
      { "]b",         "<cmd>BufferLineCycleNext<CR>",         desc = "Next buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " ", info = " " }
          local result = {}
          for k, v in pairs(diag) do
            if icons[k] then table.insert(result, icons[k] .. v) end
          end
          return table.concat(result, " ")
        end,
        offsets = {
          {
            filetype  = "NvimTree",
            text      = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- "thin" avoids slant-separator artifacts with transparent backgrounds
        separator_style = "thin",
        always_show_bufferline = false,
      },
    },
  },

  -- ── nvim-notify — styled notifications ────────────────────
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
    },
    init = function()
      vim.notify = require("notify")
    end,
  },

  -- ── Noice — reimagined cmdline / notifications UI ─────────
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    event = "VeryLazy",
    keys = {
      { "<leader>un", "<cmd>NoiceDismiss<CR>", desc = "Dismiss notifications" },
      { "<C-f>",
        function()
          if not require("noice.lsp").scroll(4) then return "<C-f>" end
        end,
        silent = true, expr = true, desc = "Scroll docs forward", mode = { "i", "n", "s" }
      },
      { "<C-b>",
        function()
          if not require("noice.lsp").scroll(-4) then return "<C-b>" end
        end,
        silent = true, expr = true, desc = "Scroll docs back", mode = { "i", "n", "s" }
      },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
  },

  -- ── Alpha — startup dashboard ─────────────────────────────
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "                                                     ",
        "                   |  /\\  |  |\\  |                  ",
        "                   | /  \\ |  | \\ |                  ",
        "                   |/ /\\ \\|  |  \\|                  ",
        "                    /  \\    |   |                   ",
        "                                                     ",
        "                    v a i n i m                      ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       "<cmd>Telescope find_files<CR>"),
        dashboard.button("e", "  New file",         "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files",     "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text",        "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Config",           "<cmd>e " .. vim.fn.stdpath("config") .. "/init.lua<CR>"),
        dashboard.button("l", "󰒲  Lazy",             "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit",             "<cmd>qa<CR>"),
      }

      alpha.setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ " .. stats.loaded .. "/" .. stats.count
            .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ── Indent Blankline — visual indent guides ────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = true },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "neo-tree", "lazy",
          "mason", "notify", "toggleterm", "lazyterm",
        },
      },
    },
  },

  -- ── Todo Comments — highlight TODO/FIXME/NOTE etc. ────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                           desc = "Find TODOs" },
      { "<leader>xt", "<cmd>TodoTrouble<CR>",                             desc = "TODOs (Trouble)" },
    },
    opts = {
      signs = true,
      keywords = {
        FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning",  alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "default",  alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint",     alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test",    alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  -- ── Web Devicons ───────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── NUI (UI component library for noice etc.) ─────────────
  { "MunifTanjim/nui.nvim", lazy = true },
}
