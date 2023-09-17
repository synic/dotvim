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
        ignore = {}, -- { ".DS_Store", "node_modules" } etc.
        devicons = {
          enable = true,
          highlight_dirname = true,
        },
        mappings = {

          ["l"] = actions.edit,
          ["<return>"] = actions.edit,
          ["<C-s>"] = actions.split,
          ["<C-v>"] = actions.vsplit,
          ["S"] = actions.split,
          ["<C-t>"] = actions.tabedit,

          ["h"] = actions.up,
          ["q"] = actions.quit,
          ["<esc>"] = actions.quit,

          ["K"] = actions.mkdir,
          ["N"] = actions.newfile,
          ["R"] = actions.rename,
          ["@"] = actions.cd,
          ["Y"] = actions.yank_path,
          ["."] = actions.toggle_show_hidden,
          ["D"] = actions.delete,

          ["J"] = function()
            mark_actions.toggle_mark()
            vim.cmd("normal! j")
          end,
          ["C"] = clipboard_actions.copy,
          ["X"] = clipboard_actions.cut,
          ["P"] = clipboard_actions.paste,
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

      vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })

      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "lir" },
        callback = function()
          -- use visual mode
          vim.api.nvim_buf_set_keymap(
            0,
            "x",
            "J",
            ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )

          -- echo cwd
          vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
        end,
      })
    end,
  },

  -- not sure why, but need to add an empty table at the end here. If there's only one plugin in the module, and it
  -- also includes functions, lazy.nvim complains that `find` is called on a nil value. Not sure why this works, but
  -- there you have it.
  {},
}
