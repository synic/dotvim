local function netrw_current_file()
  local pathname = vim.fn.expand("%:p:h")
  vim.fn.execute("edit " .. pathname)
end

local function netrw_current_project()
  local pathname = vim.fn.ProjectRootGuess()
  vim.fn.execute("edit " .. pathname)
end

vim.g.netrw_liststyle = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_browse_split = 0

vim.keymap.set("n", "-", netrw_current_file, { desc = "browse current directory" })
vim.keymap.set("n", "<leader>-", netrw_current_file, { desc = "browse current directory" })
vim.keymap.set("n", "_", netrw_current_project, { desc = "browse project directory" })
vim.keymap.set("n", "<leader>_", netrw_current_project, { desc = "browse project directory" })

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
}
