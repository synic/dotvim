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

    vim.cmd.normal("O" .. name)
    vim.cmd.write({ mods = { silent = true } })
  end)
end

return {
  {
    "stevearc/oil.nvim",
    opts = {
      columns = {
        "permissions",
        "size",
        "mtime",
        { "icon", add_padding = false },
      },
      skip_confirm_for_simple_edits = true,
      lsp_rename_autosave = true,
      keymaps = {
        ["<CR>"] = "actions.select",
        ["g/"] = "actions.select_vsplit",
        ["g-"] = "actions.select_split",
        ["gt"] = "actions.select_tab",
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
        ["h"] = "actions.parent",
        ["l"] = "actions.select",
      },
      use_default_keymaps = true,
    },
    dependencies = { "nvim-tree/nvim-web-devicons", "synic/project.nvim" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          local oil = require("oil")
          local dir = oil.get_current_dir()

          if dir then
            vim.cmd.cd(dir)
          end
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
