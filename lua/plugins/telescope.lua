-- ============================================================
-- Fuzzy Finder — Telescope
-- ============================================================

local project_root_cache = {}

local function project_root(path)
  local root_key = path or ""
  if root_key == "" then
    root_key = vim.uv.cwd() or ""
    project_root_cache[root_key] = root_key
    return root_key
  end

  local stat = vim.uv.fs_stat(root_key)
  if stat and stat.type == "file" then
    root_key = vim.fs.dirname(root_key)
  end
  if project_root_cache[root_key] ~= nil then
    return project_root_cache[root_key]
  end

  local candidates = vim.fs.find(".git", {
    path = root_key,
    upward = true,
    type = "any",
    limit = 1,
  })
  if #candidates == 0 then
    project_root_cache[root_key] = root_key
    return root_key
  end

  local root = vim.fs.dirname(candidates[1])
  project_root_cache[root_key] = root
  return root
end

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Native FZF sorter (much faster)
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release "
             .. "&& cmake --build build --config Release",
        enabled = vim.fn.executable("cmake") == 1,
      },
      -- Use Telescope for vim.ui.select
      "nvim-telescope/telescope-ui-select.nvim",
      -- File browser extension
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
      -- Files
      {
        "<leader>ff",
        function()
          local builtin = require("telescope.builtin")
          local path = vim.api.nvim_buf_get_name(0)
          if path == "" then
            path = vim.uv.cwd() or ""
          end
          local root = project_root(path)
          if root and vim.uv.fs_stat(vim.fs.joinpath(root, ".git")) then
            builtin.git_files({
              cwd = root,
              show_untracked = false,
            })
          else
            vim.notify("No Git repository found; showing files via find_files", vim.log.levels.WARN)
            builtin.find_files({ cwd = root })
          end
        end,
        desc = "Find files",
      },
      { "<leader>fF", "<cmd>Telescope find_files<CR>",                   desc = "Find files (all, incl. hidden)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                     desc = "Recent files" },
      {
        "<leader>fb",
        function()
          local builtin = require("telescope.builtin")
          pcall(require("telescope").load_extension, "file_browser")
          if type(builtin.file_browser) == "function" then
            builtin.file_browser()
            return
          end
          vim.notify("file_browser extension is not available", vim.log.levels.WARN)
        end,
        desc = "File browser",
      },
      -- Grep
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",                    desc = "Live grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>",                  desc = "Grep word under cursor" },
      -- Buffers
      { "<leader>,",  "<cmd>Telescope buffers sort_mru=true<CR>",        desc = "Switch buffer" },
      -- Git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>",                  desc = "Git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",                   desc = "Git status" },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>",                 desc = "Git branches" },
      -- LSP
      { "<leader>ld", "<cmd>Telescope lsp_definitions<CR>",              desc = "LSP definitions" },
      { "<leader>lr", "<cmd>Telescope lsp_references<CR>",               desc = "LSP references" },
      { "<leader>li", "<cmd>Telescope lsp_implementations<CR>",          desc = "LSP implementations" },
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>",         desc = "Document symbols" },
      { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<CR>",        desc = "Workspace symbols" },
      -- Misc
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",                    desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>",                      desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<CR>",                     desc = "Commands" },
      { "<leader>fC", "<cmd>Telescope colorscheme<CR>",                  desc = "Colorschemes" },
      { "<leader>fm", "<cmd>Telescope marks<CR>",                        desc = "Marks" },
      { "<leader>fo", "<cmd>Telescope vim_options<CR>",                  desc = "Vim options" },
      { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<CR>",    desc = "Fuzzy search buffer" },
      { "<leader>:",  "<cmd>Telescope command_history<CR>",              desc = "Command history" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local has_fd = vim.fn.executable("fd") == 1
      local has_rg = vim.fn.executable("rg") == 1

      local function make_find_command()
        if has_fd then
          return { "fd", "--type", "f", "--strip-cwd-prefix", "--exclude", ".git", "--exclude", "node_modules", "--exclude", ".cache" }
        end
        if has_rg then
          return { "rg", "--files", "--hidden", "--glob", "!.git", "--glob", "!node_modules", "--glob", "!.cache" }
        end
        return nil
      end

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = "> ",
          entry_prefix = "  ",
          path_display = { "smart" },
          preview = {
            treesitter = false,
          },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-n>"]   = actions.cycle_history_next,
              ["<C-p>"]   = actions.cycle_history_prev,
              ["<C-j>"]   = actions.move_selection_next,
              ["<C-k>"]   = actions.move_selection_previous,
              ["<C-c>"]   = actions.close,
              ["<Down>"]  = actions.move_selection_next,
              ["<Up>"]    = actions.move_selection_previous,
              ["<CR>"]    = actions.select_default,
              ["<C-x>"]   = actions.select_horizontal,
              ["<C-v>"]   = actions.select_vertical,
              ["<C-t>"]   = actions.select_tab,
              ["<C-u>"]   = actions.preview_scrolling_up,
              ["<C-d>"]   = actions.preview_scrolling_down,
              ["<C-q>"]   = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"]   = actions.complete_tag,
              ["<C-_>"]   = actions.which_key,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"]  = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["j"]     = actions.move_selection_next,
              ["k"]     = actions.move_selection_previous,
              ["H"]     = actions.move_to_top,
              ["M"]     = actions.move_to_middle,
              ["L"]     = actions.move_to_bottom,
              ["gg"]    = actions.move_to_top,
              ["G"]     = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["?"]     = actions.which_key,
            },
          },
          -- Ignore common non-source directories
          file_ignore_patterns = {
            "%.git/", "node_modules/", "%.cache/", "__pycache__/",
            "%.o$", "%.a$", "%.out$", "%.class$", "%.pdf$",
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            find_command = make_find_command(),
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          file_browser = {
            theme = "ivy",
            hijack_netrw = false,
          },
        },
      })

      -- Load extensions (safe, skips missing native builds)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
      -- file_browser is only loaded when used to reduce first-open cost.

      -- nvim-treesitter v1.0 compatibility shims for telescope's buffer previewer.
      -- (1) parsers.ft_to_lang was removed — delegate to native vim.treesitter API
      local ok_p, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok_p and type(parsers) == "table" and not parsers.ft_to_lang then
        parsers.ft_to_lang = function(ft)
          return vim.treesitter.language.get_lang(ft) or ft
        end
      end
      -- (2) configs.is_enabled was removed — telescope calls this to check if
      -- treesitter highlighting is available for a given language in the preview.
      -- Return true if the parser for the language is actually installed.
      local ok_c, ts_cfg = pcall(require, "nvim-treesitter.configs")
      if ok_c and type(ts_cfg) == "table" and not ts_cfg.is_enabled then
        ts_cfg.is_enabled = function(module, lang, _bufnr)
          if module ~= "highlight" then return false end
          return pcall(vim.treesitter.language.inspect, lang)
        end
      end
    end,
  },
}
