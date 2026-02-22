-- ============================================================
-- File Explorer — nvim-tree
-- ============================================================

return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e",  "<cmd>NvimTreeToggle<CR>", desc = "Toggle Explorer" },
      { "<leader>E",  "<cmd>NvimTreeFocus<CR>",  desc = "Focus Explorer" },
    },
    init = function()
      -- Must be set before nvim-tree loads to disable netrw completely
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },

        view = {
          width = 35,
          side  = "left",
        },

        renderer = {
          group_empty    = true,
          highlight_git  = true,
          icons = {
            show = {
              file         = true,
              folder       = true,
              folder_arrow = true,
              git          = true,
              modified     = true,
            },
            glyphs = {
              default  = "",
              symlink  = "",
              bookmark = "󰆤",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open   = "",
                default      = "",
                open         = "",
                empty        = "",
                empty_open   = "",
                symlink      = "",
                symlink_open = "",
              },
              git = {
                unstaged  = "✗",
                staged    = "✓",
                unmerged  = "",
                renamed   = "➜",
                untracked = "★",
                deleted   = "",
                ignored   = "◌",
              },
            },
          },
        },

        filters = {
          dotfiles = false,
          custom   = { "^.git$", "node_modules" },
        },

        git = {
          enable       = true,
          ignore       = false,
          show_on_dirs = true,
          timeout      = 400,
        },

        diagnostics = {
          enable       = true,
          show_on_dirs = true,
          icons = {
            hint    = "",
            info    = "",
            warning = "",
            error   = "",
          },
        },

        actions = {
          open_file = {
            quit_on_open  = false,
            resize_window = true,
          },
        },

        update_focused_file = {
          enable      = true,
          update_root = false,
        },

        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          -- Start from defaults, then add custom bindings
          api.config.mappings.default_on_attach(bufnr)

          local function map(key, fn, desc)
            vim.keymap.set("n", key, fn, {
              buffer  = bufnr,
              desc    = "nvim-tree: " .. desc,
              noremap = true,
              silent  = true,
              nowait  = true,
            })
          end

          map("v", api.node.open.vertical,   "Open: Vertical Split")
          map("s", api.node.open.horizontal, "Open: Horizontal Split")
          map("t", api.node.open.tab,        "Open: New Tab")
          map("l", api.node.open.edit,       "Open")
          map("h", api.node.navigate.parent_close, "Collapse")
          map("?", api.tree.toggle_help,     "Help")
        end,
      })
    end,
  },
}
