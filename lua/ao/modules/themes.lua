return {
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "medium"
    end,
  },
  { "folke/tokyonight.nvim", lazy = true },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(opts)
          if opts.match:find("^rose%-pine") ~= nil then
            vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
          end
        end,
      })
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
  { "joshdick/onedark.vim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  {
    "neanias/everforest-nvim",
    lazy = false,
    opts = {
      background = "hard",
      ui_contrast = "high",
    },
    config = function(opts)
      require("everforest").setup(opts)
    end,
  },
  { "bluz71/vim-nightfly-colors", lazy = true },
  { "NLKNguyen/papercolor-theme", lazy = true },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "romainl/Apprentice", lazy = true },
}
