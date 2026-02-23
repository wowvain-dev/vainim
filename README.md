# vainim - personal nvim config

I am not maintaining this config for anybody but myself, so as long as it still works for me it is unlikely that I will address an issue someone might create.

Requires Neovim 0.11+. Space is leader. On first launch, lazy.nvim bootstraps itself and installs everything.

## Structure

```
lua/
  config/
    options.lua       vim options
    keymaps.lua       core keybindings
    autocmds.lua      autocommands (yank highlight, cursor restore, transparent bg, etc.)
    theme.lua         theme persistence helpers
    theme_picker.lua  floating theme picker with live preview
  plugins/
    colorscheme.lua   catppuccin, tokyonight, gruvbox, rose-pine, kanagawa
    ui.lua            lualine, bufferline, noice, nvim-notify, alpha dashboard, indent-blankline
    explorer.lua      nvim-tree
    telescope.lua     telescope + fzf-native + file-browser
    treesitter.lua    treesitter + textobjects
    completion.lua    blink.cmp + LuaSnip + friendly-snippets
    lsp.lua           mason + mason-lspconfig + nvim-lspconfig
    formatting.lua    conform.nvim (format) + nvim-lint (lint) + mason-tool-installer
    git.lua           gitsigns + toggleterm (lazygit)
    editor.lua        which-key, Comment, autopairs, nvim-surround, flash, trouble,
                      colorizer, inc-rename
  lsp/
    servers.lua       edit this to add/remove language servers
scripts/
  setup.ps1           creates the Windows junction to %LOCALAPPDATA%\nvim
```

## Plugins

| Category       | Plugin(s) |
|----------------|-----------|
| Plugin manager | lazy.nvim |
| Colorschemes   | catppuccin, tokyonight, gruvbox.nvim, rose-pine, kanagawa |
| Statusline     | lualine |
| Bufferline     | bufferline.nvim |
| Notifications  | nvim-notify + noice.nvim |
| Dashboard      | alpha-nvim |
| Explorer       | nvim-tree |
| Fuzzy finding  | telescope.nvim + fzf-native + file-browser |
| Syntax         | nvim-treesitter + treesitter-textobjects |
| Completion     | blink.cmp + LuaSnip + friendly-snippets |
| LSP            | nvim-lspconfig + mason.nvim + mason-lspconfig |
| Formatting     | conform.nvim + nvim-lint + mason-tool-installer |
| Git            | gitsigns.nvim + toggleterm (lazygit) |
| Navigation     | flash.nvim |
| Editing        | Comment.nvim, nvim-autopairs, nvim-surround, inc-rename |
| UI helpers     | which-key, nvim-colorizer, todo-comments, trouble.nvim |
| Indent guides  | indent-blankline |

## Language servers

Edit `lua/lsp/servers.lua` to add or remove servers — Mason installs them automatically on next launch.

Defaults: lua, python (basedpyright), typescript, html, css, json, yaml, bash, c/c++, rust, odin, markdown.

GDScript is handled separately (not via Mason) — connects to Godot's built-in LSP on port 6005. Godot must be open when editing `.gd` files.

## Key bindings

```
<leader>ff   find files           <leader>e    explorer toggle
<leader>fg   live grep            <leader>tg   lazygit
<leader>ut   theme picker         <leader>tt   floating terminal
<leader>ub   toggle transparency  <leader>un   cycle line numbers
<leader>lm   Mason                <leader>ca   code action
<leader>rn   rename symbol        <leader>x    trouble diagnostics
```

Press Space and wait for which-key to see everything else.
