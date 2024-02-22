local utils = require("ao.utils")

local function gitsigns_on_attach(bufnr)
  local gs = package.loaded.gitsigns

  utils.map_keys({
    -- stylua: ignore start
    { "]h", gs.next_hunk, desc = "Next hunk", buffer = bufnr },
    { "[h", gs.prev_hunk, desc = "Prev hunk", buffer = bufnr },
    { "ghs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk", buffer = bufnr, modes = {"n", "v"} },
    { "ghr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset hunk", buffer = bufnr, modes = {"n", "v"} },
    { "ghS", gs.stage_buffer, desc = "Stage buffer", buffer = bufnr },
    { "ghu", gs.undo_stage_hunk, desc = "Undo stage Hunk", buffer = bufnr },
    { "ghR", gs.reset_buffer, desc = "Reset buffer", buffer = bufnr },
    { "ghp", gs.preview_hunk, desc = "Preview hunk", buffer = bufnr },
    { "ghb", function() gs.blame_line({ full = true }) end, desc = "Blame line", buffer = bufnr },
    { "ghd", gs.diffthis, desc = "Diff this", buffer = bufnr },
    { "ghD", function() gs.diffthis("~") end, desc = "Diff this ~", buffer = bufnr },
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

  -- git blame
  {
    "FabijanZulj/blame.nvim",
    keys = {
      { "<leader>gb", "<cmd>ToggleBlame virtual<cr>", desc = "Git blame" },
      { "<leader>gB", "<cmd>ToggleBlame window<cr>", desc = "Git blame (window)" },
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
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    keys = {
      { "<leader>gs", neogit_open, desc = "Git status" },
    },
    opts = {
      kind = "auto",
      commit_editor = { kind = "auto" },
      commit_select_view = { kind = "auto" },
      log_view = { kind = "auto" },
      rebase_editor = { kind = "auto" },
      reflog_view = { kind = "auto" },
      merge_editor = { kind = "auto" },
      description_editor = { kind = "auto" },
      tag_editor = { kind = "auto" },
      preview_buffer = { kind = "split" },
      popup = { kind = "split" },
      commit_view = {
        kind = "vsplit",
        verify_commit = vim.fn.executable("gpg") == 1,
      },
    },
  },
}
