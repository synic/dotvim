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

local function change_to_project_root()
  local r = utils.find_project_root()
  if r then
    vim.cmd.cd(r)
  end
end

local function touch()
  local oil = require("oil")
  local path = require("plenary.path")

  vim.ui.input({ prompt = "Create file (or directory): " }, function(name)
    if name == nil then
      return
    end

    if name == "." or name == ".." then
      print("Invalid file name: " .. name)
      return
    end

    local dir = oil.get_current_dir()
    if not dir then
      return
    end

    local p = path:new(dir .. name)
    if p:exists() then
      print("File already exists: ", path.filename)
      return
    end

    if string.find(p.filename, ".*/$") ~= nil then
      p:mkdir()
    else
      p:touch()
    end

    vim.cmd.edit({ bang = true })
  end)
end

return {
  {
    "stevearc/oil.nvim",
    opts = function()
      local oil = require("oil")
      local actions = require("oil.actions")

      return {
        columns = {
          "permissions",
          "size",
          "mtime",
          { "icon", add_padding = false },
        },
        skip_confirm_for_simple_edits = true,
        lsp_rename_autosave = true,
        add_padding = false,
        keymaps = {
          ["<CR>"] = {
            desc = "Select",
            callback = function()
              actions.select.callback(nil, change_to_project_root)
            end,
          },
          ["g/"] = {
            desc = "Open in vertical split",
            callback = function()
              oil.select({ vertical = true }, change_to_project_root)
            end,
          },
          ["g-"] = {
            desc = "Open in horizontal split",
            callback = function()
              oil.select({ horizontal = true }, change_to_project_root)
            end,
          },
          ["gt"] = {
            desc = "Open in new tab",
            callback = function()
              oil.select({ tab = true }, change_to_project_root)
            end,
          },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["gn"] = {
            desc = "Create new file",
            callback = function()
              touch()
            end,
          },
          ["g\\"] = "actions.toggle_trash",
          ["g."] = "actions.toggle_hidden",
          ["h"] = {
            desc = "parent",
            callback = function()
              require("oil.actions").parent.callback()
              change_to_project_root()
            end,
          },
          ["l"] = {
            desc = "select",
            callback = function()
              require("oil.actions").select.callback(nil, change_to_project_root)
            end,
          },
        },
        use_default_keymaps = true,
      }
    end,
    dependencies = { "nvim-tree/nvim-web-devicons", "ahmedkhalf/project.nvim" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = change_to_project_root,
      })
    end,
  },

  -- fancy replacement for netrw, with devicons
  -- {
  --   "tamago324/lir.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   config = function()
  --     local actions = require("lir.actions")
  --     local mark_actions = require("lir.mark.actions")
  --     local clipboard_actions = require("lir.clipboard.actions")
  --
  --     require("lir").setup({
  --       show_hidden_files = true,
  --       devicons = { enable = true },
  --       ignore = { ".mypy_cache", ".git", ".tmp", "node_modules", "*_templ.go", ".DS_Store" },
  --       mappings = {
  --         ["l"] = actions.edit,
  --         ["<return>"] = actions.edit,
  --         ["<C-s>"] = actions.split,
  --         ["<C-v>"] = actions.vsplit,
  --         ["g/"] = actions.vsplit,
  --         ["g-"] = actions.split,
  --         ["<C-t>"] = actions.tabedit,
  --
  --         ["h"] = actions.up,
  --         ["q"] = actions.quit,
  --         ["<esc>"] = actions.quit,
  --
  --         ["gk"] = actions.mkdir,
  --         ["gn"] = touch,
  --         ["gr"] = actions.rename,
  --         ["gR"] = actions.reload,
  --         ["gy"] = actions.yank_path,
  --         ["g."] = actions.toggle_show_hidden,
  --         ["gd"] = delete,
  --         ["gD"] = actions.wipeout,
  --
  --         ["gm"] = function()
  --           mark_actions.toggle_mark()
  --           vim.cmd("normal! j")
  --         end,
  --         ["gc"] = clipboard_actions.copy,
  --         ["gx"] = clipboard_actions.cut,
  --         ["gp"] = clipboard_actions.paste,
  --       },
  --       float = {
  --         winblend = 0,
  --         curdir_window = {
  --           enable = false,
  --           highlight_dirname = false,
  --         },
  --       },
  --       hide_cursor = true,
  --     })
  --
  --     vim.api.nvim_create_autocmd({ "FileType" }, {
  --       pattern = { "lir" },
  --       callback = function()
  --         -- use visual mode
  --         vim.api.nvim_buf_set_keymap(
  --           0,
  --           "x",
  --           "m",
  --           ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
  --           { noremap = true, silent = true }
  --         )
  --
  --         -- echo cwd
  --         vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
  --       end,
  --     })
  --   end,
  -- },
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
