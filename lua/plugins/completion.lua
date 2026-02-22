-- ============================================================
-- Completion — blink.cmp (modern, fast, native)
-- ============================================================

return {
  {
    "saghen/blink.cmp",
    -- Uses pre-built binaries from GitHub releases — no Rust/cargo needed
    version = "*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- Optional: use LuaSnip as the snippet engine for custom snippets
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = vim.fn.has("win32") == 0
          and "make install_jsregexp"
          or nil,
        config = function()
          -- Load VS Code-style snippets from friendly-snippets
          require("luasnip.loaders.from_vscode").lazy_load()
          -- Load any project-local snippets from .vscode/snippets/
          require("luasnip.loaders.from_vscode").lazy_load({
            paths = { vim.fn.getcwd() .. "/.vscode/snippets" },
          })
        end,
      },
    },
    event = "InsertEnter",
    opts = {
      -- ── Keymap ───────────────────────────────────────────────
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },
        ["<CR>"]      = { "accept", "fallback" },
        ["<Tab>"]     = { "snippet_forward",  "select_next", "fallback" },
        ["<S-Tab>"]   = { "snippet_backward", "select_prev", "fallback" },
        ["<Up>"]      = { "select_prev", "fallback" },
        ["<Down>"]    = { "select_next", "fallback" },
        ["<C-p>"]     = { "select_prev", "fallback" },
        ["<C-n>"]     = { "select_next", "fallback" },
        ["<C-b>"]     = { "scroll_documentation_up",   "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
        ["<C-k>"]     = { "show_documentation", "hide_documentation" },
      },

      -- ── Appearance ───────────────────────────────────────────
      appearance = {
        nerd_font_variant = "mono",
      },

      -- ── Completion ───────────────────────────────────────────
      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            -- kind_icon on the left, label on the right (no text label for kind)
            columns = {
              { "kind_icon", gap = 1 },
              { "label", "label_description", gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = false },
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
      },

      -- ── Snippets — use LuaSnip ────────────────────────────────
      snippets = { preset = "luasnip" },

      -- ── Sources ───────────────────────────────────────────────
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            score_offset = 4,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 3,
            opts = { show_hidden_files_by_default = true },
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            score_offset = 2,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            score_offset = 1,
          },
        },
      },

      -- ── Signature help ────────────────────────────────────────
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      -- ── Fuzzy matching ────────────────────────────────────────
      fuzzy = {
        implementation = "prefer_rust",
      },
    },
  },
}
