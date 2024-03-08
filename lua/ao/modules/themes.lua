vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
    vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
    vim.api.nvim_set_hl(0, "SignatureMarkText", { link = "DiagnosticSignInfo" })
  end,
})

local keys = {
  { "<leader>st", "<cmd>ColorSchemePicker<cr>", desc = "List themes" },
}

local builtins = {
  "zellner",
  "torte",
  "slate",
  "shine",
  "ron",
  "quiet",
  "peachpuff",
  "pablo",
  "murphy",
  "lunaperche",
  "koehler",
  "industry",
  "evening",
  "elflord",
  "desert",
  "delek",
  "default",
  "darkblue",
  "blue",
  "zaibatsu",
}

vim.api.nvim_create_user_command("ColorSchemePicker", function()
  local target = vim.fn.getcompletion

  vim.fn.getcompletion = function()
    return vim.tbl_filter(function(color)
      return not vim.tbl_contains(builtins, color)
      ---@diagnostic disable-next-line: redundant-parameter
    end, target("", "color"))
  end

  vim.cmd.Telescope("colorscheme")
  vim.fn.getcompletion = target
end, {})

return {
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    keys = vim.deepcopy(keys),
    config = function()
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
    keys = vim.deepcopy(keys),
    config = function()
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
          end
        end,
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    keys = vim.deepcopy(keys),
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(opts)
          if opts.match:find("^catppuccin") ~= nil then
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
    keys = vim.deepcopy(keys),
    opts = {
      background = "hard",
      ui_contrast = "high",
    },
    config = function(_, opts)
      require("everforest").setup(opts)
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(o)
          if o.match:find("^everforest") ~= nil then
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
  { "folke/tokyonight.nvim", lazy = true, keys = vim.deepcopy(keys) },
  { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true, keys = vim.deepcopy(keys) },
  { "rebelot/kanagawa.nvim", lazy = true, keys = vim.deepcopy(keys) },
  { "Mofiqul/dracula.nvim", lazy = true, keys = vim.deepcopy(keys) },
  { "joshdick/onedark.vim", lazy = true, keys = vim.deepcopy(keys) },
  { "EdenEast/nightfox.nvim", lazy = true, keys = vim.deepcopy(keys) },
  {
    "AlexvZyl/nordic.nvim",
    lazy = true,
    keys = vim.deepcopy(keys),
    config = function()
      require("nordic").load()
    end,
  },
  {
    "ribru17/bamboo.nvim",
    lazy = true,
    keys = vim.deepcopy(keys),
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function(o)
          if o.match:find("^bamboo") ~= nil then
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
            vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
            vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
          end
        end,
      })
      require("bamboo").setup({
        -- optional configuration here
      })
      require("bamboo").load()
    end,
  },
}
