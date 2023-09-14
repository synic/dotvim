return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium"
    end,
    config = function()
      vim.cmd("colorscheme gruvbox-material")
    end,
  },
  { "folke/tokyonight.nvim", lazy = true },
}
