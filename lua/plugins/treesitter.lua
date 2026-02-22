-- ============================================================
-- Syntax Highlighting & Text Objects — Treesitter
-- ============================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<C-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    config = function()
      require("nvim-treesitter").setup({
        -- Install these parsers automatically
        ensure_installed = {
          "bash", "c", "cpp", "css", "dockerfile",
          "go", "gomod", "gowork", "gosum",
          "html", "javascript", "jsdoc", "json", "json5", "jsonc",
          "lua", "luadoc", "luap",
          "markdown", "markdown_inline",
          "python", "query",
          "regex", "rust",
          "toml", "tsx", "typescript",
          "vim", "vimdoc",
          "xml", "yaml",
        },
        auto_install = true,
        sync_install = false,

        highlight = {
          enable = true,
          -- Disable for very large files
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },

        indent = { enable = true },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = false,
            node_decremental  = "<bs>",
          },
        },

        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- Around / inside function
              ["af"] = { query = "@function.outer",   desc = "Around function" },
              ["if"] = { query = "@function.inner",   desc = "Inside function" },
              -- Around / inside class
              ["ac"] = { query = "@class.outer",      desc = "Around class" },
              ["ic"] = { query = "@class.inner",      desc = "Inside class" },
              -- Around / inside block
              ["ab"] = { query = "@block.outer",      desc = "Around block" },
              ["ib"] = { query = "@block.inner",      desc = "Inside block" },
              -- Around / inside parameter
              ["aa"] = { query = "@parameter.outer",  desc = "Around argument" },
              ["ia"] = { query = "@parameter.inner",  desc = "Inside argument" },
              -- Around / inside conditional
              ["ai"] = { query = "@conditional.outer", desc = "Around if" },
              ["ii"] = { query = "@conditional.inner", desc = "Inside if" },
              -- Around / inside loop
              ["al"] = { query = "@loop.outer",       desc = "Around loop" },
              ["il"] = { query = "@loop.inner",       desc = "Inside loop" },
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function" },
              ["]c"] = { query = "@class.outer",    desc = "Next class" },
              ["]a"] = { query = "@parameter.inner", desc = "Next argument" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
              ["]C"] = { query = "@class.outer",    desc = "Next class end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev function" },
              ["[c"] = { query = "@class.outer",    desc = "Prev class" },
              ["[a"] = { query = "@parameter.inner", desc = "Prev argument" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Prev function end" },
              ["[C"] = { query = "@class.outer",    desc = "Prev class end" },
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>na"] = { query = "@parameter.inner", desc = "Swap next argument" },
              ["<leader>nm"] = { query = "@function.outer",  desc = "Swap next method" },
            },
            swap_previous = {
              ["<leader>pa"] = { query = "@parameter.inner", desc = "Swap prev argument" },
              ["<leader>pm"] = { query = "@function.outer",  desc = "Swap prev method" },
            },
          },
          lsp_interop = {
            enable = true,
            border = "rounded",
            peek_definition_code = {
              ["<leader>pf"] = "@function.outer",
              ["<leader>pc"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
}
