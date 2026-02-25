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

local function gdscript_cmd()
  local port = tonumber(os.getenv("GDScript_Port") or os.getenv("GDSCRIPT_PORT")) or 6005
  return vim.lsp.rpc.connect("127.0.0.1", port)
end

local function gdscript_root_dir(fname)
  local root = vim.fs.find({ "project.godot", ".git" }, {
    path = vim.fs.dirname(fname),
    upward = true,
    type = "file",
    limit = 1,
  })
  if root and root[1] then
    return vim.fs.dirname(root[1])
  end

  -- Fall back to the current directory so the client always attaches.
  return vim.uv.cwd()
end

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
    on_new_config = function(config)
      config.settings = config.settings or {}
      config.settings.json = config.settings.json or {}
      config.settings.json.schemaStore = { enable = false, url = "" }
      config.settings.json.schemas = require("schemastore").json.schemas()
    end,
    settings = {
      json = {
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    on_new_config = function(config)
      config.settings = config.settings or {}
      config.settings.yaml = config.settings.yaml or {}
      config.settings.yaml.schemaStore = { enable = false, url = "" }
      config.settings.yaml.schemas = require("schemastore").yaml.schemas()
    end,
    settings = {
      yaml = {
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
        cargo = {
          allFeatures = false,
          loadOutDirsFromCheck = false,
          buildScripts = { enable = false },
        },
        check = {
          command = "check",
        },
        checkOnSave = false,
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
  gdscript = {
    cmd = gdscript_cmd(),
    root_dir = gdscript_root_dir,
    filetypes = { "gd", "gdscript", "gdscript3" },
    root_markers = { "project.godot", ".git" },
    single_file_support = true,
  },

  -- ── Documentation ──────────────────────────────────────────
  marksman = {},

  -- ── Docker ─────────────────────────────────────────────────
  -- dockerls = {},
  -- docker_compose_language_service = {},

}
