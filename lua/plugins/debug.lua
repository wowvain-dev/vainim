-- ============================================================
-- Debugging & Testing — nvim-dap + dap-ui + neotest
-- ============================================================

return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    lazy = true,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
      "nvim-telescope/telescope-dap.nvim",
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug continue/start" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug conditional breakpoint" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Debug step out" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug run last" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI toggle" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug eval" },
      { "<leader>df", "<cmd>Telescope dap frames<CR>", desc = "Debug frames" },
      { "<leader>dv", "<cmd>Telescope dap variables<CR>", desc = "Debug variables" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local mason_dap = require("mason-nvim-dap")

      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        controls = {
          enabled = true,
          element = "repl",
        },
        floating = {
          border = "rounded",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.45 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.15 },
              { id = "breakpoints", size = 0.15 },
            },
            size = 44,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
      })

      mason_dap.setup({
        ensure_installed = { "python", "codelldb" },
        automatic_installation = false,
        handlers = {
          function(config)
            mason_dap.default_setup(config)
          end,
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      local debugpy_python = vim.fs.joinpath(
        vim.fn.stdpath("data"),
        "mason",
        "packages",
        "debugpy",
        "venv",
        "Scripts",
        "python.exe"
      )
      require("dap-python").setup(vim.fn.executable(debugpy_python) == 1 and debugpy_python or "python")
      require("dap-go").setup()

      pcall(require("telescope").load_extension, "dap")
    end,
  },

  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-plenary",
      "marilari88/neotest-vitest",
      "mfussenegger/nvim-dap",
    },
    keys = {
      { "<leader>Tr", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>TS", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Test suite (cwd)" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test output" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Test output panel" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Test watch file" },
      { "<leader>Tt", function() require("neotest").run.stop() end, desc = "Stop test run" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            dap = { justMyCode = false },
          }),
          require("neotest-go")({
            experimental = { test_table = true },
          }),
          require("neotest-plenary"),
          require("neotest-vitest")({}),
        },
        output = {
          open_on_run = false,
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        floating = {
          border = "rounded",
          max_height = 0.85,
          max_width = 0.85,
        },
        summary = {
          open = false,
        },
        status = {
          virtual_text = true,
        },
      })
    end,
  },
}
