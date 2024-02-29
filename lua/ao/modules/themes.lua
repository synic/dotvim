local M = {
  have_loaded_all_plugins = false,
}

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
    vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
  end,
})

M.plugin_specs = {
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "medium"

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(opts)
          if opts.match:find("^gruvbox") ~= nil then
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
            vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
          end
        end,
      })
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
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
            vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "SignatureMarkText", { fg = "#f38ba8" })
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
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
            vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
          end
        end,
      })
    end,
  },
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = true,
    opts = {
      background = "hard",
      ui_contrast = "high",
    },

    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(opts)
          if opts.match:find("^everforest") ~= nil then
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#555555" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
            vim.api.nvim_set_hl(0, "NonText", { fg = "#555555" })
            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#555555" })
            vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#555555" })
          end
        end,
      })
    end,
  },
  { "folke/tokyonight.nvim", lazy = true },
  { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "joshdick/onedark.vim", lazy = true },
}

-- make sure that all the themes are loaded before showing the picker
M.load_themes_and_pick = function()
  if not M.have_loaded_all_plugins then
    local config = require("lazy.core.config")
    local to_load = {}

    for _, spec in ipairs(M.plugin_specs) do
      local loc = (type(spec) == "string" and spec or spec[1])
      for _, plugin in pairs(config.plugins) do
        if plugin[1] == loc then
          table.insert(to_load, plugin)
        end
      end
    end

    require("lazy.core.loader").load(to_load, {})
    M.have_loaded_all_plugins = true
  end
  vim.cmd.Telescope("colorscheme")
end

return M
