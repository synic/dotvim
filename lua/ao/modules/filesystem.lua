local keymap = require("ao.keymap")
local utils = require("ao.utils")
local module = {}

module.netrw_current_file = function()
  local pathname = vim.fn.expand("%:p:h")
  vim.fn.execute("edit " .. pathname)
end

module.netrw_current_project = function()
  local status, project = pcall(require, "project_nvim.project")

  if not status then
    print("Unable to determine project root")
    return
  end

  local pathname, _ = project.get_project_root()

  vim.fn.execute("edit " .. pathname)
end

keymap.netrw()

vim.g.netrw_liststyle = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_browse_split = 0

return utils.table_concat(module, {
  {
    "tamago324/lir.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lir").setup({
        show_hidden_files = false,
        ignore = {}, -- { ".DS_Store", "node_modules" } etc.
        devicons = {
          enable = true,
          highlight_dirname = true,
        },
        mappings = keymap.lir(),
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
})
