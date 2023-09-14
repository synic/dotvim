return {
  {
    "Lokaltog/vim-easymotion",
    init = function()
      vim.g.EasyMotion_smartcase = true
      vim.g.EasyMotion_do_mapping = false
    end,
    keys = {
      { "<leader><leader>", "<plug>(easymotion-overwin-f)", desc = "jump to location", mode = "n" },
      { "<leader><leader>", "<plug>(easymotion-bd-f)", desc = "jump to location", mode = "v" },
    },
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
    keys = {
      {
        "s",
        mode = { "n", "o", "x" },
        function()
          require("flash").jump()
        end,
        desc = "flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "flash treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "remote flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "treesitter search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "toggle flash search",
      },
    },
  },
  "editorconfig/editorconfig-vim",
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
  {
    "mbbill/undotree",
    keys = { { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "undo tree" } },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        show_end_of_line = true,
      })

      vim.opt.list = true
      vim.opt.listchars:append("eol:↴")
    end,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    lazy = true,
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
