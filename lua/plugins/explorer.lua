-- ============================================================
-- File Explorer — nvim-tree
-- ============================================================

return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus" },
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
      local function neutralize_untracked_git_highlights()
        local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
        local neutral_untracked_hl = vim.tbl_deep_extend("force", {
          fg = comment_hl.fg or comment_hl.foreground,
          bg = comment_hl.bg or comment_hl.background,
          ctermfg = comment_hl.ctermfg,
          ctermbg = comment_hl.ctermbg,
          italic = false,
          bold = false,
          underline = false,
          undercurl = false,
          strikethrough = false,
        }, {})

        local function fix_group(group)
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
          if ok and type(hl) == "table" then
            vim.api.nvim_set_hl(0, group, vim.tbl_deep_extend("force", hl, neutral_untracked_hl))
          else
            vim.api.nvim_set_hl(0, group, neutral_untracked_hl)
          end
        end

        -- Neutralize all nvim-tree git-related highlight groups, not just the likely
        -- set, so renamed/unexpected group names also become non-italic gray.
        for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
          if group:find("^NvimTree") and group:find("Git") then
            fix_group(group)
          end
        end

        -- Explicitly neutralize gitsigns untracked variations as well.
        local gitsigns_untracked_groups = {
          "GitSignsUntracked",
          "GitSignsUntrackedNr",
          "GitSignsUntrackedLn",
          "GitSignsUntrackedCul",
          "GitSignsStagedUntracked",
          "GitSignsStagedUntrackedNr",
          "GitSignsStagedUntrackedLn",
          "GitSignsStagedUntrackedCul",
        }
        for _, group in ipairs(gitsigns_untracked_groups) do
          fix_group(group)
        end
      end

      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },

        view = {
          width = 35,
          side  = "left",
        },

        renderer = {
          group_empty    = true,
          highlight_git  = "name",
          indent_markers = {
            enable = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "└",
              none = " ",
            },
          },
          icons = {
            git_placement = "right_align",
            modified_placement = "after",
            show = {
              file         = true,
              folder       = true,
              folder_arrow = false,
              git          = true,
              modified     = false,
            },
            glyphs = {
              default  = "",
              symlink  = "",
              bookmark = "󰆤",
              modified = "",
              folder = {
                arrow_closed = "",
                arrow_open   = "",
                default      = "",
                open         = "",
                empty        = "",
                empty_open   = "",
                symlink      = "",
                symlink_open = "",
              },
              git = {
                unstaged  = "M",
                staged    = "M",
                unmerged  = "!",
                renamed   = "R",
                untracked = "?",
                deleted   = "D",
                ignored   = "",
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
            hint    = " ",
            info    = " ",
            warning = " ",
            error   = " ",
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
          -- Highlight the full line under cursor when hovering/focusing the tree.
          vim.wo.cursorline = true
          vim.wo.cursorlineopt = "both"
          vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { link = "CursorLine" })
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

      neutralize_untracked_git_highlights()

      local untracked_hl_group = vim.api.nvim_create_augroup("vainim_untracked_highlights", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = untracked_hl_group,
        callback = neutralize_untracked_git_highlights,
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = untracked_hl_group,
        pattern = "NvimTree",
        callback = neutralize_untracked_git_highlights,
      })
      vim.api.nvim_create_autocmd("WinEnter", {
        group = untracked_hl_group,
        callback = function()
          if vim.bo.filetype == "NvimTree" then
            neutralize_untracked_git_highlights()
          end
        end,
      })
    end,
  },
}
