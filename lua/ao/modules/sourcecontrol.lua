local utils = require("ao.utils")

local function gitsigns_on_attach(bufnr)
  local gs = package.loaded.gitsigns

  utils.map_keys({
		-- stylua: ignore start
		{ "]h", gs.next_hunk, desc = "next hunk", buffer = bufnr },
		{ "[h", gs.prev_hunk, desc = "prev hunk", buffer = bufnr },
		{ modes={ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", desc = "stage hunk", buffer = bufnr },
		{ modes={ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", desc = "reset hunk", buffer = bufnr },
		{ "<leader>ghS", gs.stage_buffer, desc = "stage buffer", buffer = bufnr },
		{ "<leader>ghu", gs.undo_stage_hunk, desc = "undo stage Hunk", buffer = bufnr },
		{ "<leader>ghR", gs.reset_buffer, desc = "reset buffer", buffer = bufnr },
		{ "<leader>ghp", gs.preview_hunk, desc = "preview hunk", buffer = bufnr },
		{ "<leader>ghb", function() gs.blame_line({ full = true }) end, desc = "blame line", buffer = bufnr },
		{ "<leader>ghd", gs.diffthis, desc = "diff this", buffer = bufnr },
		{ "<leader>ghD", function() gs.diffthis("~") end, desc = "diff this ~", buffer = bufnr },
		{ modes={ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", desc = "select hunk", buffer = bufnr },
  })
end

-- Open NeoGit
--
-- This function goes through all the buffers and closes any that are
-- the neogit status buffer, and _then_ opens NeoGit. This is because if you
-- open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. NeoGit is already open, even if you can't see it.
local function neogit_open()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "filetype") == "NeogitStatus" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  require("neogit").open({ cwd = "%:p:h" })
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
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "git blame" },
      { "<leader>ga", "<cmd>Git add %<cr>", desc = "git add" },
    },
  },

  -- show git status in gutter, allow staging of hunks
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
      on_attach = gitsigns_on_attach,
    },
  },

  -- git client
  {
    "NeogitOrg/neogit",
    opts = { kind = "vsplit" },
    keys = {
      { "<leader>gs", neogit_open, desc = "git status" },
    },
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  },
}
