-- ============================================================
-- Core Keymaps  (Space = leader, set in init.lua)
-- Plugin-specific bindings live in their own plugin files.
-- ============================================================

local map = vim.keymap.set

-- ── Escape ──────────────────────────────────────────────────
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("i", "kj", "<ESC>", { desc = "Exit insert mode" })

-- ── Clear ───────────────────────────────────────────────────
map("n", "<leader>nh", ":nohl<CR>",       { desc = "Clear search highlights" })
map("n", "x",          '"_x',             { noremap = true, silent = true })

-- ── Window navigation ────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- ── Window resize ────────────────────────────────────────────
map("n", "<C-Up>",    "<cmd>resize +2<CR>",          { desc = "Increase height" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",          { desc = "Decrease height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- ── Window splits ────────────────────────────────────────────
map("n", "<leader>sv", "<C-w>v",           { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s",           { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=",           { desc = "Equal split sizes" })
map("n", "<leader>sx", "<cmd>close<CR>",   { desc = "Close split" })

-- ── Buffers ──────────────────────────────────────────────────
map("n", "<S-h>",      "<cmd>bprevious<CR>",       { desc = "Prev buffer" })
map("n", "<S-l>",      "<cmd>bnext<CR>",           { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>",         { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>",        { desc = "Force delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>",      { desc = "Close other buffers" })
map("n", "<leader>bv", "<cmd>vsplit<CR>",          { desc = "Split buffer vertical" })
map("n", "<leader>bs", "<cmd>split<CR>",           { desc = "Split buffer horizontal" })

-- ── Tabs ─────────────────────────────────────────────────────
map("n", "<leader>to", "<cmd>tabnew<CR>",   { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>",     { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>",     { desc = "Prev tab" })

-- ── Move lines ───────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==",          { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",          { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",          { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",          { desc = "Move selection up" })

-- ── Indenting ────────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ── Centered scrolling ───────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n",     "nzzzv",   { desc = "Next match (centered)" })
map("n", "N",     "Nzzzv",   { desc = "Prev match (centered)" })

-- ── Paste without overwriting register ───────────────────────
map("v", "p",  '"_dP', { noremap = true, silent = true })
map("x", "p",  '"_dP', { noremap = true, silent = true })

-- ── Save / Quit ──────────────────────────────────────────────
map({ "n", "i" }, "<C-s>", "<cmd>w<CR><ESC>",  { desc = "Save file" })
map("n", "<leader>w",      "<cmd>w<CR>",        { desc = "Save file" })
map("n", "<leader>q",      "<cmd>q<CR>",        { desc = "Quit" })
map("n", "<leader>Q",      "<cmd>qa!<CR>",      { desc = "Quit all (force)" })
map("n", "<leader>wq",     "<cmd>wq<CR>",       { desc = "Save and quit" })

-- ── Select all ───────────────────────────────────────────────
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- ── Diagnostics ──────────────────────────────────────────────
map("n", "[d",        vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "]d",        vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

-- ── UI toggles ───────────────────────────────────────────────

-- Line numbers: cycle  relative (hybrid) → absolute → off → relative
map("n", "<leader>un", function()
  local nu  = vim.opt.number:get()
  local rnu = vim.opt.relativenumber:get()
  if nu and rnu then
    -- hybrid → absolute only
    vim.opt.relativenumber = false
    vim.notify("Line numbers: absolute", vim.log.levels.INFO)
  elseif nu then
    -- absolute → off
    vim.opt.number = false
    vim.notify("Line numbers: off", vim.log.levels.INFO)
  else
    -- off → hybrid (relative + absolute current line)
    vim.opt.number         = true
    vim.opt.relativenumber = true
    vim.notify("Line numbers: relative", vim.log.levels.INFO)
  end
end, { desc = "Cycle line numbers (relative → absolute → off)" })

-- Line wrap
map("n", "<leader>uw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle line wrap" })

-- Transparent background (terminal bg shows through)
map("n", "<leader>ub", function()
  vim.g.vainim_transparent = not vim.g.vainim_transparent
  -- Re-trigger ColorScheme autocmd by re-applying the current theme
  pcall(vim.cmd.colorscheme, vim.g.colors_name)
  vim.notify(
    "Background: " .. (vim.g.vainim_transparent and "transparent" or "solid"),
    vim.log.levels.INFO
  )
end, { desc = "Toggle transparent background" })

-- Theme picker
map("n", "<leader>ut", function()
  require("config.theme_picker").open()
end, { desc = "Theme picker" })
