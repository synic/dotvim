local keymap = require("ao.keymap")

return {
  {
    "Lokaltog/vim-easymotion",
    init = function()
      vim.g.EasyMotion_smartcase = true
      vim.g.EasyMotion_do_mapping = false
    end,
    keys = keymap.easymotion,
  },
  {
    "folke/flash.nvim",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm.,/'-",
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    lazy = false,
    keys = keymap.flash,
  },
  "editorconfig/editorconfig-vim",
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
  {
    "tpope/vim-commentary",
    event = "InsertEnter",
  },
  {
    "mbbill/undotree",
    keys = keymap.undotree,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("indent_blankline").setup({
        show_end_of_line = true,
      })

      vim.opt.list = true
      vim.opt.listchars:append("eol:↴")
      vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#444444" })
    end,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
