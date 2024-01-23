local utils = require("ao.utils")

local function browse_at_current_directory()
  local pathname = vim.fn.expand("%:p:h")
  vim.fn.execute("edit " .. pathname)
end

local function browse_at_project_directory()
  local status, project = pcall(require, "project_nvim.project")

  if not status then
    print("Unable to determine project root")
    return
  end

  local pathname, _ = project.get_project_root()

  vim.fn.execute("edit " .. pathname)
end

utils.map_keys({
  { "-", browse_at_current_directory, desc = "Browse current directory" },
  { "<leader>-", browse_at_current_directory, desc = "Browse current directory" },
  { "_", browse_at_project_directory, desc = "Browse current project" },
  { "<leader>_", browse_at_project_directory, desc = "Browse current project" },
})

vim.g.netrw_liststyle = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_browse_split = 0

local function delete()
  local lvim = require("lir.vim")
  local actions = require("lir.actions")
  local path = require("plenary.path")
  local ctx = lvim.get_context()

  local items = ctx:get_marked_items()
  local count = #items

  if #items == 0 then
    actions.delete()
  else
    if vim.fn.confirm("Delete " .. count .. " items?", "&Yes\n&No", 1) ~= 1 then
      return
    end

    for _, item in pairs(items) do
      local p = path:new(item.fullpath)
      if p:is_dir() then
        p:rm({ recursive = true })
      else
        if not vim.loop.fs_unlink(p:absolute()) then
          utils.error("Delete file failed")
          return
        end
      end
    end

    actions.reload()
  end
end

local function touch()
  local actions = require("lir.actions")
  local path = require("plenary.path")
  local lvim = require("lir.vim")

  vim.ui.input({ prompt = "Create file (or directory): " }, function(name)
    if name == nil then
      return
    end

    if name == "." or name == ".." then
      utils.error("Invalid file name: " .. name)
      return
    end

    local ctx = lvim.get_context()
    local p = path:new(ctx.dir .. name)
    if p:exists() then
      utils.error("File already exists")
      -- cursor jump
      local lnum = ctx:indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
      return
    end

    if string.find(p.filename, ".*/$") ~= nil then
      p:mkdir()
    else
      p:touch()
    end

    actions.reload()

    vim.schedule(function()
      local lnum = lvim.get_context():indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
    end)
  end)
end

return {
  -- fancy replacement for netrw, with devicons
  {
    "tamago324/lir.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local actions = require("lir.actions")
      local mark_actions = require("lir.mark.actions")
      local clipboard_actions = require("lir.clipboard.actions")

      require("lir").setup({
        show_hidden_files = false,
        devicons = {
          enable = true,
          highlight_dirname = true,
        },
        mappings = {
          ["l"] = actions.edit,
          ["<return>"] = actions.edit,
          ["<C-s>"] = actions.split,
          ["<C-v>"] = actions.vsplit,
          ["g/"] = actions.vsplit,
          ["g-"] = actions.split,
          ["<C-t>"] = actions.tabedit,

          ["h"] = actions.up,
          ["q"] = actions.quit,
          ["<esc>"] = actions.quit,

          ["gk"] = actions.mkdir,
          ["gn"] = touch,
          ["gr"] = actions.rename,
          ["gR"] = actions.reload,
          ["gy"] = actions.yank_path,
          ["g."] = actions.toggle_show_hidden,
          ["gd"] = delete,
          ["gD"] = actions.wipeout,

          ["gm"] = function()
            mark_actions.toggle_mark()
            vim.cmd("normal! j")
          end,
          ["gc"] = clipboard_actions.copy,
          ["gx"] = clipboard_actions.cut,
          ["gp"] = clipboard_actions.paste,
        },
        float = {
          winblend = 0,
          curdir_window = {
            enable = false,
            highlight_dirname = false,
          },
        },
        hide_cursor = true,
      })

      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "lir" },
        callback = function()
          -- use visual mode
          vim.api.nvim_buf_set_keymap(
            0,
            "x",
            "m",
            ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )

          -- echo cwd
          vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
        end,
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>pt", "<cmd>NvimTreeToggle<cr>", desc = "File tree" },
    },
    opts = {
      hijack_netrw = false,
      sync_root_with_cwd = true,
      reload_on_bufenter = true,
      hijack_cursor = true,
      filters = {
        dotfiles = true,
      },
      git = {
        enable = false,
        ignore = true,
      },
      filesystem_watchers = {
        enable = true,
      },
      renderer = {
        root_folder_label = false,
        highlight_git = false,
        highlight_opened_files = "none",

        indent_markers = {
          enable = false,
        },

        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = false,
          },

          glyphs = {
            default = "󰈚",
            symlink = "",
            folder = {
              default = "",
              empty = "",
              empty_open = "",
              open = "",
              symlink = "",
              symlink_open = "",
              arrow_open = "",
              arrow_closed = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
    },
  },
}
