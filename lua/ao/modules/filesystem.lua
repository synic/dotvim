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

return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
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
            require("oil.actions").select.callback(nil, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
        ["<C-s>"] = {
          desc = "open in vertical split",
          callback = function()
            require("oil").select({ vertical = true }, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
        ["<C-h>"] = {
          desc = "open in horizontal split",
          callback = function()
            require("oil").select({ horizontal = true }, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
        ["<C-t>"] = {
          desc = "open in new tab",
          callback = function()
            require("oil").select({ tab = true }, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["h"] = {
          desc = "parent",
          callback = function()
            require("oil.actions").parent.callback(nil, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
        ["l"] = {
          desc = "select",
          callback = function()
            require("oil.actions").select.callback(nil, function()
              local d = require("oil").get_current_dir()
              if d then
                vim.cmd.cd(d)
              end
            end)
          end,
        },
      },
      use_default_keymaps = true,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "oil",
        callback = function()
          local d = require("oil").get_current_dir()
          if d then
            vim.cmd.cd(d)
          end
        end,
      })
    end,
    keys = {
      { "<localleader>s", "<cmd>lua require'oil.actions'.change_sort.callback()<cr>", desc = "change sort" },
      { "<localleader>x", "<cmd>lua require'oil.actions'.open_external.callback()<cr>", desc = "open external" },
      { "<localleader>t", "<cmd>lua require'oil.actions'.toggle_trash.callback()<cr>", desc = "toggle trash" },
      { "<localleader>.", "<cmd>lua require'oil.actions'.toggle_hidden.callback()<cr>", desc = "toggle hidden" },
    },
  },
}
