local utils = require("ao.utils")

vim.g.neovide_remember_window_size = false

local function indent_blankline_toggle()
  local ibl = require("ibl")
  local conf = require("ibl.config")

  local enabled = not conf.get_config(-1).enabled
  ibl.update({ enabled = enabled })
  vim.opt.list = enabled
end

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
      { "<leader>tz", "<cmd>TZMinimalist<cr>", desc = "Toggle zen mode" },
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
    opts = {
      sections = {
        lualine_c = {
          {
            "filename",
            file_status = true, -- displays file status (readonly status, modified status)
            path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
          },
        },
      },
    },
  },

  -- toggle golden ratio
  {
    "roman/golden-ratio",
    keys = {
      { "<leader>tg", golden_ratio_toggle, desc = "Golden Ratio" },
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
      { "<leader><leader>", "<plug>(easymotion-overwin-f)", desc = "Jump to location", mode = "n" },
      { "<leader><leader>", "<plug>(easymotion-bd-f)", desc = "Jump to location", mode = "v" },
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
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle flash search",
      },
    },
  },

  -- search
  {
    "dyng/ctrlsf.vim",
    cmd = { "CtrlSF" },
    keys = {

      { "<leader>sf", search_in_project_root, desc = "Search in project root" },
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
  {
    "haya14busa/incsearch.vim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- show indent guide
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    lazy = true,
    keys = {
      { "<leader>ti", indent_blankline_toggle, desc = "Toggle indent guide" },
    },
    config = function()
      local ibl = require("ibl")
      local hooks = require("ibl.hooks")
      local conf = require("ibl.config")

      local exclude = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "NeoGitStatus",
        "markdown",
        "lazy",
        "mazon",
        "NvimTree",
        "Trouble",
        "text",
      }

      if vim.g.colors_name == "gruvbox-material" or vim.g.colors_name:find("^rose-pine") ~= nil then
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
          vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
          vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
          vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
          vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
          vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
          vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
        end)
      end

      if vim.g.colors_name == "everforest" then
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
          vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444" })
          vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#555555" })
          vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
          vim.api.nvim_set_hl(0, "NonText", { fg = "#555555" })
          vim.api.nvim_set_hl(0, "Whitespace", { fg = "#555555" })
          vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#555555" })
        end)
      end

      ibl.setup({
        whitespace = { remove_blankline_trail = false },
        scope = { enabled = false },
        exclude = { filetypes = exclude },
        indent = { char = "|" },
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          vim.opt.list = not utils.table_contains(exclude, vim.bo.filetype) and conf.get_config(-1).enabled
        end,
      })

      vim.opt.listchars:append("eol:↴")
    end,
  },

  { "nvim-treesitter/nvim-treesitter-context", event = { "BufReadPre", "BufNewFile" } },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
  },
}
