local utils = require("ao.utils")

vim.g.neovide_remember_window_size = true

local function indent_blankline_toggle()
  local ibl = require("ibl")
  local conf = require("ibl.config")

  local enabled = not conf.get_config(-1).enabled
  ibl.update({ enabled = enabled })
  vim.opt.list = enabled
end

local function lualine_trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
  return function(str)
    local win_width = vim.fn.winwidth(0)
    if hide_width and win_width < hide_width then
      return ""
    elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
      return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
    end
    return str
  end
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

  -- zen mode (maximize windows, etc)
  {
    "pocco81/true-zen.nvim",
    keys = {
      { "<leader>tz", "<cmd>TZMinimalist<cr>", desc = "Toggle zen mode" },
    },
  },

  -- various interface and vim scripting utilities
  {
    "tpope/vim-scriptease",
    lazy = false,
    keys = {
      { "<leader>sm", "<cmd>Messages<cr>", desc = "Show notifications/messages" },
    },
  },

  -- show indent scope
  {
    "echasnovski/mini.indentscope",
    version = false,
    lazy = false,
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- highlight css and other colors
  {
    "norcalli/nvim-colorizer.lua",
    name = "colorizer",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      "javascript",
      "css",
      "html",
      "templ",
      "sass",
      "scss",
      "typescript",
      "json",
    },
  },

  -- show marks in gutter
  "kshenoy/vim-signature",

  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<localleader>,",
        "<cmd>lua require('dropbar.api').pick()<cr>",
        desc = "Dropbar picker",
      },
    },
    opts = function()
      local dutils = require("dropbar.utils")
      local preview = false
      local ignore = { "gitcommit" }
      return {
        general = {
          enable = function(buf, win)
            return vim.fn.win_gettype(win) == ""
              and vim.wo[win].winbar == ""
              and vim.bo[buf].bt == ""
              and not utils.table_contains(ignore, vim.bo[buf].ft)
              and (
                vim.bo[buf].ft == "markdown"
                or (
                  buf
                    and vim.api.nvim_buf_is_valid(buf)
                    and (pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft))
                    and true
                  or false
                )
              )
          end,
        },
        menu = {
          preview = preview,
          keymaps = {
            ["q"] = "<C-w>q",
            ["h"] = "<C-w>q",
            ["<LeftMouse>"] = function()
              local menu = dutils.menu.get_current()
              if not menu then
                return
              end
              local mouse = vim.fn.getmousepos()
              local clicked_menu = dutils.menu.get({ win = mouse.winid })
              -- If clicked on a menu, invoke the corresponding click action,
              -- else close all menus and set the cursor to the clicked window
              if clicked_menu then
                clicked_menu:click_at({
                  mouse.line,
                  mouse.column - 1,
                }, nil, 1, "l")
                return
              end
              dutils.menu.exec("close")
              dutils.bar.exec("update_current_context_hl")
              if vim.api.nvim_win_is_valid(mouse.winid) then
                vim.api.nvim_set_current_win(mouse.winid)
              end
            end,
            ["l"] = function()
              local menu = dutils.menu.get_current()
              if not menu then
                return
              end
              local cursor = vim.api.nvim_win_get_cursor(menu.win)
              local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
              if component then
                menu:click_on(component, nil, 1, "l")
              end
            end,
            ["<MouseMove>"] = function()
              local menu = dutils.menu.get_current()
              if not menu then
                return
              end
              local mouse = vim.fn.getmousepos()
              dutils.menu.update_hover_hl(mouse)
              if preview then
                dutils.menu.update_preview(mouse)
              end
            end,
            ["i"] = function()
              local menu = dutils.menu.get_current()
              if not menu then
                return
              end
              menu:fuzzy_find_open()
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      require("dropbar").setup(opts)
      vim.ui.select = require("dropbar.utils.menu").select
    end,
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },

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
      options = {
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_b = {
          {
            "branch",
            fmt = lualine_trunc(200, 30, 100),
          },
          { "diff" },
          { "diagnostics" },
        },
        lualine_x = {
          { "encoding", fmt = lualine_trunc(0, 0, 120) },
          { "fileformat", fmt = lualine_trunc(0, 0, 120) },
          { "filetype", fmt = lualine_trunc(0, 0, 120) },
        },
        lualine_y = {
          { "progress", fmt = lualine_trunc(0, 0, 100) },
        },
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

      if
        vim.g.colors_name == "gruvbox-material"
        or vim.g.colors_name:find("^catppuccin") ~= nil
        or vim.g.colors_name:find("^rose-pine") ~= nil
      then
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

  -- fidget.nvim shows lsp and null-ls status at the bottom right of the screen
  { "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach", opts = {} },

  -- automatically close inactive buffers
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
  },
}
