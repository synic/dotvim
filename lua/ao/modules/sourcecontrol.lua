local utils = require("ao.utils")
local keymap = require("ao.keymap")

local module = {}

-- Open NeoGit
--
-- This function goes through all the buffers and closes any that are
-- the neogit status buffer, and _then_ opens NeoGit. This is because if you
-- open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. NeoGit is already open, even if you can't see it.
module.neogit_open = function()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "filetype") == "NeogitStatus" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  require("neogit").open({ cwd = "%:p:h" })
end

return utils.table_concat(module, {
  {
    "akinsho/git-conflict.nvim",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    config = true,
  },
  {
    "tpope/vim-fugitive",
    keys = keymap.fugitive,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    lazy = false,
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = keymap.gitsigns_on_attach,
    },
  },
  {
    "NeogitOrg/neogit",
    opts = { kind = "vsplit" },
    keys = keymap.neogit,
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  },
})
