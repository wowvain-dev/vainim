-- ============================================================
-- LSP SERVER LIST
-- ============================================================
-- Add or remove servers here to control what Mason installs
-- and what nvim-lspconfig configures.
--
-- Each key is an lspconfig server name. The value is a table
-- of config overrides (use {} for sensible defaults).
--
-- Full list of supported servers:
--   https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- ============================================================

return {

  -- ── Lua ────────────────────────────────────────────────────
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        format = { enable = false }, -- use stylua via conform instead
      },
    },
  },

  -- ── Python ─────────────────────────────────────────────────
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "basic",
        },
      },
    },
  },
  -- pyright = {},   -- alternative: classic pyright

  -- ── TypeScript / JavaScript ────────────────────────────────
  ts_ls = {},

  -- ── Web ────────────────────────────────────────────────────
  html      = {},
  cssls     = {},
  -- tailwindcss = {},  -- uncomment if you use Tailwind

  -- ── Data / Config formats ──────────────────────────────────
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
        validate = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- ── Shell ──────────────────────────────────────────────────
  bashls = {},

  -- ── Systems programming ────────────────────────────────────
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true },
        checkOnSave = { command = "clippy" },
        procMacro = { enable = true },
        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          lifetimeElisionHints = { enable = "never" },
          parameterHints = { enable = false },
          typeHints = { enable = true },
        },
      },
    },
  },
  ols = {},

  -- ── Go ─────────────────────────────────────────────────────
  -- Requires Go to be installed (https://go.dev/dl/) — uncomment when ready
  -- gopls = {
  --   settings = {
  --     gopls = {
  --       analyses  = { unusedparams = true, shadow = true },
  --       staticcheck = true,
  --       gofumpt = true,
  --       hints = {
  --         assignVariableTypes    = true,
  --         compositeLiteralFields = true,
  --         compositeLiteralTypes  = true,
  --         constantValues         = true,
  --         functionTypeParameters = true,
  --         parameterNames         = true,
  --         rangeVariableTypes     = true,
  --       },
  --     },
  --   },
  -- },

  -- ── Godot / GDScript ───────────────────────────────────────
  -- gdscript is NOT listed here — it is NOT installed by Mason.
  -- Godot 4 ships its own LSP server (port 6005 by default).
  -- Configured directly in lua/plugins/lsp.lua.

  -- ── Documentation ──────────────────────────────────────────
  marksman = {},

  -- ── Docker ─────────────────────────────────────────────────
  -- dockerls = {},
  -- docker_compose_language_service = {},

}
