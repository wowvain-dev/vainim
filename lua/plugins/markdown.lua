-- ============================================================
-- Markdown Rendering — markview.nvim
-- ============================================================

return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        icon_provider = "devicons",
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview toggle<CR>",      desc = "Toggle markdown preview" },
      { "<leader>uM", "<cmd>Markview splitToggle<CR>", desc = "Toggle markdown split preview" },
    },
  },
}
