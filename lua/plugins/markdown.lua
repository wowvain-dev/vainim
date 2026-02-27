-- ============================================================
-- Markdown Rendering — render-markdown.nvim
-- ============================================================

local RENDER_MODES = { "n", "c", "t" }
local FILE_TYPES = { "markdown", "markdown.pandoc", "rmd", "quarto", "vimwiki", "wiki" }

local function default_options()
  return {
    enabled = false,
    render_modes = RENDER_MODES,
    file_types = FILE_TYPES,
    overrides = {
      buftype = {
        nofile = {
          enabled = false,
          render_modes = false,
        },
      },
    },
    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = "" },
    },
    anti_conceal = {
      enabled = true,
      ignore = {
        code_background = true,
        link_url = true,
      },
    },
  }
end

local function get_preview_buffer_for_source(source_buf)
  local preview = require("render-markdown.core.preview")
  if not vim.api.nvim_buf_is_valid(source_buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and preview.get(buf) == source_buf then
      return buf
    end
  end
  return nil
end

local function get_preview_window_for_source(source_buf)
  if not vim.api.nvim_buf_is_valid(source_buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not vim.api.nvim_win_is_valid(win) then
      goto continue
    end
    local buf = vim.api.nvim_win_get_buf(win)
    if not vim.api.nvim_buf_is_valid(buf) then
      goto continue
    end
    if require("render-markdown.core.preview").get(buf) == source_buf then
      return win
    end

    ::continue::
  end
  return nil
end

local function markdown_source_buffer()
  local current = vim.api.nvim_get_current_buf()
  local preview = require("render-markdown.core.preview")
  return preview.get(current) or current
end

local function close_markdown_preview_window(source_buf)
  local preview_buf = get_preview_buffer_for_source(source_buf)
  if not preview_buf then
    return false
  end
  pcall(vim.api.nvim_buf_delete, preview_buf, { force = true })
  return true
end

local function toggle_markdown_split_preview()
  local renderer = require("render-markdown")
  local preview = require("render-markdown.core.preview")

  local source_buf = markdown_source_buffer()
  if close_markdown_preview_window(source_buf) then
    return
  end

  local ok, err = pcall(preview.open, source_buf)
  if not ok then
    vim.notify(("Failed to open markdown preview: %s"):format(err), vim.log.levels.ERROR)
    return
  end

  local preview_win = get_preview_window_for_source(source_buf)
  if preview_win then
    local preview_buf = vim.api.nvim_win_get_buf(preview_win)
    pcall(renderer.render, {
      buf = preview_buf,
      win = preview_win,
    })
  end
end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = FILE_TYPES,
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    ---@module "render-markdown"
    opts = default_options,
    keys = {
      {
        "<leader>m",
        toggle_markdown_split_preview,
        desc = "Open markdown preview (split right)",
      },
      {
        "<leader>M",
        "<cmd>RenderMarkdown buf_toggle<cr>",
        desc = "Toggle markdown rendering (current buffer)",
      },
    },
  },
}
