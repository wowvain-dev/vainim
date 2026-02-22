-- ============================================================
-- Formatting — conform.nvim
-- Linting  — nvim-lint
-- ============================================================

return {
  -- ── conform.nvim: fast, async formatter ────────────────────
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer/selection",
      },
    },
    opts = {
      -- ── Formatters per filetype ─────────────────────────────
      -- Multiple formatters run in sequence. Use `stop_after_first = true`
      -- to use only the first available one.
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "ruff_format", "ruff_organize_imports" },
        javascript = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        javascriptreact  = { "prettier" },
        typescriptreact  = { "prettier" },
        css        = { "prettier" },
        scss       = { "prettier" },
        html       = { "prettier" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        graphql    = { "prettier" },
        go         = { "goimports", "gofumpt" },
        rust       = { "rustfmt" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        toml       = { "taplo" },
        ["_"]      = { "trim_whitespace" }, -- fallback for any ft
      },

      -- ── Format on save ────────────────────────────────────
      format_on_save = function(bufnr)
        -- Disable for certain filetypes or large files
        local disable_filetypes = { "c", "cpp" }
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("/node_modules/") then return end
        for _, ft in ipairs(disable_filetypes) do
          if vim.bo[bufnr].filetype == ft then return end
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,

      -- ── Formatter-specific options ────────────────────────
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
        prettier = {
          prepend_args = { "--prose-wrap", "always" },
        },
      },

      log_level = vim.log.levels.WARN,
      notify_on_error = true,
    },
  },

  -- ── nvim-lint: async linting ───────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python     = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        lua        = { "luacheck" },
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        go         = { "golangcilint" },
        markdown   = { "markdownlint" },
        yaml       = { "yamllint" },
      }

      -- Auto-lint on these events
      local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Only lint if a linter is configured for the filetype
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Run linter" })
    end,
  },

  -- ── mason-tool-installer: auto-install formatters & linters ─
  -- Ensures these tools are always available via Mason.
  -- Add any tool you want auto-installed:
  --   https://mason-registry.dev/registry/list
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",
        "prettier",
        "shfmt",
        "taplo",
        -- Linters / language tools
        "ruff",
        "luacheck",
        "shellcheck",
        "markdownlint",
        "yamllint",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
    },
  },
}
