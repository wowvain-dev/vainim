-- ============================================================
-- LSP — Mason + mason-lspconfig + nvim-lspconfig
-- Language servers are configured in lua/lsp/servers.lua
-- ============================================================

return {
  -- ── Mason: install & manage LSP servers, DAP, linters, formatters ──
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>lm", "<cmd>Mason<CR>", desc = "Open Mason" },
    },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- ── Schemastore: JSON/YAML schemas (used by jsonls & yamlls) ───────
  {
    "b0o/schemastore.nvim",
    lazy = true,
    version = false,
  },

  -- ── mason-lspconfig: bridge Mason → lspconfig ─────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    lazy = true,
  },

  -- ── nvim-lspconfig: configure all LSP servers ─────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>li", "<cmd>LspInfo<CR>",   desc = "LSP info" },
      { "<leader>lR", "<cmd>LspRestart<CR>", desc = "LSP restart" },
    },
    config = function()
      -- ── Diagnostics appearance ─────────────────────────────
      -- nvim 0.10+: configure signs via vim.diagnostic.config, not sign_define
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source   = "if_many",
          prefix   = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- ── LSP handlers ──────────────────────────────────────
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = "rounded" }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = "rounded" }
      )

      -- ── Keymaps (attached per-buffer) ──────────────────────
      local function on_attach(client, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd",         vim.lsp.buf.definition,       "Goto definition")
        map("gD",         vim.lsp.buf.declaration,      "Goto declaration")
        map("gr",         vim.lsp.buf.references,       "Goto references")
        map("gi",         vim.lsp.buf.implementation,   "Goto implementation")
        map("gt",         vim.lsp.buf.type_definition,  "Goto type definition")
        map("K",          vim.lsp.buf.hover,            "Hover docs")
        map("<C-k>",      vim.lsp.buf.signature_help,   "Signature help")
        -- <leader>rn is handled by inc-rename.nvim (editor.lua)
        map("<leader>ca", vim.lsp.buf.code_action,      "Code action")
        map("<leader>cf", vim.lsp.buf.format,           "Format buffer")
        map("<leader>wa", vim.lsp.buf.add_workspace_folder,    "Add workspace folder")
        map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        map("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")

        -- Highlight symbol under cursor
        if client.server_capabilities.documentHighlightProvider then
          local hl_group = vim.api.nvim_create_augroup("lsp_doc_highlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = hl_group })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = bufnr,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })
        end

        -- Inlay hints toggle (nvim 0.10+)
        if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
          map("<leader>uh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
          end, "Toggle inlay hints")
        end
      end

      -- ── Capabilities: blink.cmp enhances LSP completion ───
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- ── Load server configs from lua/lsp/servers.lua ──────
      local servers = require("lsp.servers")

      -- Global defaults applied to every server (nvim 0.11 native API)
      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Per-server setting overrides
      for server_name, server_opts in pairs(servers) do
        if next(server_opts) ~= nil then
          vim.lsp.config(server_name, server_opts)
        end
      end

      -- Mason: install listed servers; handler enables each one after install
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
        handlers = {
          function(server_name)
            vim.lsp.enable(server_name)
          end,
        },
      })
    end,
  },
}
