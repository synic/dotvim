local utils = require("ao.utils")

local function gitsigns_on_attach(bufnr)
  local gs = package.loaded.gitsigns

  utils.map_keys({
    -- stylua: ignore start
    { "]h", gs.next_hunk, desc = "Next hunk", buffer = bufnr },
    { "[h", gs.prev_hunk, desc = "Prev hunk", buffer = bufnr },
    { "<localleader>ghs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk", buffer = bufnr, modes = {"n", "v"} },
    { "<localleader>ghr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset hunk", buffer = bufnr, modes = {"n", "v"} },
    { "<localleader>ghS", gs.stage_buffer, desc = "Stage buffer", buffer = bufnr },
    { "<localleader>ghu", gs.undo_stage_hunk, desc = "Undo stage Hunk", buffer = bufnr },
    { "<localleader>ghR", gs.reset_buffer, desc = "Reset buffer", buffer = bufnr },
    { "<localleader>ghp", gs.preview_hunk, desc = "Preview hunk", buffer = bufnr },
    { "<localleader>ghb", function() gs.blame_line({ full = true }) end, desc = "Blame line", buffer = bufnr },
    { "<localleader>ghd", gs.diffthis, desc = "Diff this", buffer = bufnr },
    { "<localleader>ghD", function() gs.diffthis("~") end, desc = "Diff this ~", buffer = bufnr },
    { "ih", "<cmd><C-U>Gitsigns select_hunk<cr>", desc = "Select hunk", buffer = bufnr, modes = {"o", "x"} },
  })
end

-- Open NeoGit
--
-- This function goes through all the buffers and closes any that are
-- the neogit status buffer, and _then_ opens NeoGit. This is because if you
-- open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. NeoGit is already open, even if you can't see it.
local function neogit_open()
  local cwd = "%:p:h"
  local status, project = pcall(require, "project_nvim.project")

  if status then
    local project_root, _ = project.get_project_root()
    cwd = project_root
  end

  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "filetype") == "NeogitStatus" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  require("neogit").open({ cwd = cwd })
end

return {
  -- display conflicts
  {
    "akinsho/git-conflict.nvim",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    config = true,
  },

  -- git utilities
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
      { "<leader>ga", "<cmd>Git add %<cr>", desc = "Git add" },
    },
  },

  -- show git status in gutter, allow staging of hunks
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    lazy = true,
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = gitsigns_on_attach,
    },
  },

  -- git client
  {
    "NeogitOrg/neogit",
    opts = { kind = "auto" },
    keys = {
      { "<leader>gs", neogit_open, desc = "Git status" },
    },
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  },
}
