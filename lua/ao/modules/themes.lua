return {
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "medium"
    end,
  },
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
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(opts)
          if opts.match:find("^catppuccin") ~= nil then
            vim.api.nvim_set_hl(0, "SignatureMarkText", { fg = "#f38ba8" })
            vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#b4befe", bg = "#45475a" })
          end
        end,
      })
    end,
  },
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
  {
    "folke/tokyonight.nvim",
  },
}
