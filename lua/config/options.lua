-- ============================================================
-- Core Vim Options
-- ============================================================

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = ""
opt.cmdheight = 1
opt.showmode = false          -- mode shown by statusline
opt.laststatus = 3            -- global statusline

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300
opt.redrawtime = 1500

-- Scroll
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Invisible characters
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Folds (treesitter-based, but start unfolded)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Misc
opt.iskeyword:append("-")
opt.shortmess:append("c")
opt.backspace = "indent,eol,start"
opt.mouse = "a"
opt.inccommand = "split"      -- live preview of :s substitutions
opt.virtualedit = "block"     -- block selection past end of line
opt.smoothscroll = true

-- Windows: prefer PowerShell
if vim.fn.has("win32") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  opt.shellquote = ""
  opt.shellxquote = ""
end
