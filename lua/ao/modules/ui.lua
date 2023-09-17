vim.g.neovide_remember_window_size = false

local function search_in_project_root()
  vim.ui.input({ prompt = "term: " }, function(input)
    vim.cmd('CtrlSF "' .. input .. '"')
  end)
end

local function golden_ratio_toggle()
  vim.cmd.GoldenRatioToggle()
  if vim.g.golden_ratio_enabled == 0 then
    vim.g.golden_ratio_enabled = 1
    print("Enabled golden ratio")
  else
    vim.g.golden_ratio_enabled = 0
    print("Disabled golden ratio")
    vim.g.equalalways = true
    vim.cmd("wincmd =")
  end
end

return {
  -- extensible core UI hooks
  {
    "stevearc/dressing.nvim",
    opts = {},
  },

  -- zen mode
  {
    "pocco81/true-zen.nvim",
    keys = {
      { "<leader>tz", "<cmd>TZMinimalist<cr>", desc = "toggle zen mode" },
    },
  },

  -- show marks in gutter
  "kshenoy/vim-signature",

  -- fancy up those tabs
  {
    "nanozuki/tabby.nvim",
    event = "TabEnter",
    config = function()
      local theme = {
        fill = "TabLineFill",
        head = "TabLine",
        current_tab = "TabLineSel",
        tab = "TabLine",
        win = "TabLine",
        tail = "TabLine",
      }
      require("tabby.tabline").set(function(line)
        return {
          {
            { "  ", hl = theme.head },
            line.sep("", theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep("", hl, theme.fill),
              tab.is_current() and "" or "󰆣",
              tab.number(),
              tab.name(),
              tab.close_btn(""),
              line.sep("", hl, theme.fill),
              hl = hl,
              margin = " ",
            }
          end),
          line.spacer(),
          {
            line.sep("", theme.tail, theme.fill),
            { "  ", hl = theme.tail },
          },
          hl = theme.fill,
        }
      end)
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- toggle golden ratio
  {
    "roman/golden-ratio",
    keys = {
      { "<leader>tg", golden_ratio_toggle, desc = "golden Ratio" },
    },
    init = function()
      vim.g.golden_ratio_enabled = 0
      vim.g.golden_ratio_autocmd = 0
    end,
    config = function()
      vim.cmd.GoldenRatioToggle()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = vim.cmd.GoldenRatioToggle,
      })
    end,
  },

  -- baleia displays color escape codes properly.
  -- currently used to colorize the dap-repl output.
  {
    "m00qek/baleia.nvim",
    version = "v1.3.0",
    opts = {},
    lazy = true,
    init = function()
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        require("baleia").setup().once(vim.api.nvim_get_current_buf())
      end, {})
    end,
  },

  -- get around faster and easier
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

  -- jump to search results, etc
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

  -- search
  {
    "dyng/ctrlsf.vim",
    cmd = { "CtrlSF" },
    keys = {

      { "<leader>sf", search_in_project_root, desc = "search in project root" },
    },
    init = function()
      vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
      vim.g.ctrlsf_default_view_mode = "normal"
      vim.g.ctrlsf_default_root = "project+wf"
      vim.g.ctrlsf_auto_close = {
        normal = 0,
        compact = 1,
      }
      vim.g.ctrlsf_auto_focus = {
        at = "start",
      }
    end,
  },

  -- show search/replace results as they are being typed
  "haya14busa/incsearch.vim",

  -- startup screen
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local d = require("alpha.themes.startify")

      d.section.bottom_buttons.val = {
        d.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        d.button("SPC p p", "  Project list"),
        d.button("SPC s o", "󱋡 Recently opened files"),
        d.button("SPC C", "  Configuration"),
        d.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
      }

      local handle = io.popen("fortune")

      if handle then
        local fortune = handle:read("*a")
        handle:close()
        d.section.footer.val = {
          { type = "padding", val = 1 },
          { type = "text", val = fortune },
        }
      end

      -- d.config.opts.noautocmd = true

      -- vim.cmd([[autocmd User AlphaReady echo 'ready']])

      alpha.setup(d.config)
    end,
  },

  -- show indent guide
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
}
