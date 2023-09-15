local wk_categories = require("ao.keymap").categories

vim.g.neovide_remember_window_size = false

local function golden_ratio_toggle()
  vim.cmd([[:GoldenRatioToggle]])
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
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  {
    "pocco81/true-zen.nvim",
    keys = {
      { "<leader>tz", "<cmd>TZMinimalist<cr>", desc = "toggle zen mode" },
    },
  },

  "kshenoy/vim-signature",
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(wk_categories)

      vim.o.timeout = true
      vim.o.timeoutlen = 700
    end,
    opts = {
      plugins = { spelling = true },
      mode = { "n", "v" },
      layout = { align = "center" },
      triggers_blacklist = {
        i = { "f", "d" },
        v = { "f", "d" },
      },
    },
  },

  {
    "nanozuki/tabby.nvim",
    event = "TabEnter",
    config = function()
      local theme = {
        fill = "StatusLine",
        current_tab = "TabLineSel",
        tab = "TabLineFill",
      }

      require("tabby.tabline").set(function(line)
        local i = 0
        local current_index = 0
        local tab_count = 0

        line.tabs().foreach(function(tab)
          i = i + 1
          if tab.is_current() then
            current_index = i
          end
        end)

        tab_count = i
        i = 0

        return {
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            i = i + 1

            local last_item = tab.is_current() and line.sep("", hl, theme.fill)
              or line.sep("", theme.current_tab, hl)

            if i == current_index - 1 or (i == tab_count and not tab.is_current()) then
              last_item = line.sep("", hl, theme.fill)
            end

            return {
              i == 1 and "" or line.sep("", theme.fill, hl),
              tab.is_current() and "" or "󰆣",
              tab.number(),
              tab.name(),
              tab.close_btn(""),
              last_item,
              hl = hl,
              margin = " ",
            }
          end),
          hl = theme.win,
        }
      end)
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

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
      vim.cmd([[:GoldenRatioToggle]])
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd([[:GoldenRatioToggle]])
        end,
      })
    end,
  },
}
