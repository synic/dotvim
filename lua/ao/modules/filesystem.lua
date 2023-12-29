local utils = require("ao.utils")

local function browse_at_current_directory()
  local pathname = vim.fn.expand("%:p:h")
  vim.fn.execute("edit " .. pathname)
end

local function browse_at_project_directory()
  local pathname = utils.find_project_root()
  if not pathname then
    print("Unable to determine project root")
    return
  end

  vim.fn.execute("edit " .. pathname)
end

utils.map_keys({
  { "-", browse_at_current_directory, desc = "browse current directory" },
  { "<leader>-", browse_at_current_directory, desc = "browse current directory" },
  { "_", browse_at_project_directory, desc = "browse current project" },
  { "<leader>_", browse_at_project_directory, desc = "browse current project" },
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
          "icon",
        },
        skip_confirm_for_simple_edits = true,
        lsp_rename_autosave = true,
        keymaps = {
          ["<CR>"] = {
            desc = "select",
            callback = function()
              actions.select.callback(nil, change_to_project_root)
            end,
          },
          ["<C-s>"] = {
            desc = "open in vertical split",
            callback = function()
              oil.select({ vertical = true }, change_to_project_root)
            end,
          },
          ["<C-h>"] = {
            desc = "open in horizontal split",
            callback = function()
              oil.select({ horizontal = true }, change_to_project_root)
            end,
          },
          ["<C-t>"] = {
            desc = "open in new tab",
            callback = function()
              oil.select({ tab = true }, change_to_project_root)
            end,
          },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
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
}
