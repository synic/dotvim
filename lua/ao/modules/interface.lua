local utils = require("ao.utils")

local M = {}
local tab_name_key = "aotabname"

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
    vim.notify("Golden Ratio: enabled")
  else
    vim.g.golden_ratio_enabled = 0
    vim.notify("Golden Ratio: disabled")
    vim.g.equalalways = true
    vim.cmd("wincmd =")
  end
end

M.get_tab_name = function(tabnr)
  return vim.fn.gettabvar(tabnr or vim.fn.tabpagenr(), tab_name_key)
end

M.set_tab_name = function(name, tabnr, force)
  tabnr = tabnr or vim.fn.tabpagenr()
  local current = M.get_tab_name(tabnr)

  if current ~= "" and not force then
    return false
  end

  utils.set_tab_var(tabnr, tab_name_key, name)
  vim.cmd.redrawtabline()
end

local prompt_tab_name = function(tabnr)
  if tabnr == nil then
    tabnr = vim.fn.tabpagenr()
  end

  local current = vim.fn.gettabvar(tabnr, tab_name_key)

  vim.ui.input({ prompt = "Set layout name: ", default = current }, function(name)
    M.set_tab_name(name or "", tabnr, true)
  end)
end

utils.map_keys({
  { "<leader>lN", prompt_tab_name, desc = "Set layout name" },
})

M.plugin_specs = {
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

  -- notifications
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "minimal",
      stages = "fade",
      timeout = 1000,
      top_down = false,
      max_width = 100,
      max_height = 10,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
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
      "lua",
    },
  },

  -- show marks in gutter
  "kshenoy/vim-signature",

  {
    "Bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
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
      ---Set WinBar & WinBarNC background to Normal background
      ---@return nil
      local function clear_winbar_bg()
        ---@param name string
        ---@return nil
        local function _clear_bg(name)
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          if hl.bg or hl.ctermbg then
            hl.bg = nil
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, name, hl)
          end
        end

        _clear_bg("WinBar")
        _clear_bg("WinBarNC")
      end

      clear_winbar_bg()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("WinBarHlClearBg", {}),
        callback = clear_winbar_bg,
      })
      require("dropbar").setup(opts)
    end,
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
              M.get_tab_name(tab.number()) or tab.name(),
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
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm.,/'-",
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
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
    opts = {
      whitespace = { remove_blankline_trail = false },
      scope = { enabled = false },
      exclude = {
        filetypes = {
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
        },
      },
      indent = { char = "|" },
    },
    config = function(_, opts)
      local ibl = require("ibl")
      local conf = require("ibl.config")

      ibl.setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          vim.opt.list = not utils.table_contains(opts.exclude.filetypes, vim.bo.filetype)
            and conf.get_config(-1).enabled
        end,
      })

      vim.opt.listchars:append("eol:↴")
    end,
  },

  -- fidget.nvim shows lsp and null-ls status at the bottom right of the screen
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    tag = "legacy",
    config = true,
  },

  -- automatically close inactive buffers
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
  },
}

return M
