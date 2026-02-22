-- ============================================================
-- Git Integration — gitsigns + lazygit (via toggleterm)
-- ============================================================

return {
  -- ── Gitsigns: inline git blame, hunk navigation & staging ─
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      signcolumn = true,
      numhl      = false,
      linehl     = false,
      word_diff  = false,

      watch_gitdir = { follow_files = true },
      auto_attach = true,
      attach_to_untracked = false,

      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
      },
      current_line_blame_formatter = "<author>, <author_time:%d/%m/%Y> · <summary>",

      preview_config = { border = "rounded" },

      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- ── Navigation ───────────────────────────────────────
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- ── Actions ──────────────────────────────────────────
        map({ "n", "v" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>",   "Stage hunk")
        map({ "n", "v" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>",   "Reset hunk")
        map("n",          "<leader>hS", gs.stage_buffer,                  "Stage buffer")
        map("n",          "<leader>hu", gs.undo_stage_hunk,               "Undo stage hunk")
        map("n",          "<leader>hR", gs.reset_buffer,                  "Reset buffer")
        map("n",          "<leader>hp", gs.preview_hunk,                  "Preview hunk")
        map("n",          "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
        map("n",          "<leader>hB", gs.toggle_current_line_blame,     "Toggle line blame")
        map("n",          "<leader>hd", gs.diffthis,                      "Diff this")
        map("n",          "<leader>hD", function() gs.diffthis("~") end,  "Diff this ~")
        map("n",          "<leader>ht", gs.toggle_deleted,                "Toggle deleted")

        -- ── Text object (select hunk) ─────────────────────────
        map({ "o", "x" }, "ih", "<cmd><C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- ── Lazygit inside Neovim (via toggleterm) ─────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>",      desc = "Toggle terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "Toggle terminal (vertical)" },
      {
        "<leader>tg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit = Terminal:new({
            cmd = "lazygit",
            hidden = true,
            direction = "float",
            float_opts = { border = "curved" },
            on_open = function(term)
              vim.cmd("startinsert!")
              vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
            end,
            on_close = function()
              vim.cmd("startinsert!")
            end,
          })
          lazygit:toggle()
        end,
        desc = "Lazygit",
      },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = { border = "Normal", background = "Normal" },
      },
      winbar = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      -- Allow <ESC> to exit terminal mode
      local function set_terminal_keymaps()
        local o = { buffer = 0 }
        vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", o)
        vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>", o)
        vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>", o)
        vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>", o)
        vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>", o)
      end
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = set_terminal_keymaps,
      })
    end,
  },
}
