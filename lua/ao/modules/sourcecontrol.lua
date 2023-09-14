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
  {
    "akinsho/git-conflict.nvim",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    config = true,
  },
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gb", ":Git blame<cr>", desc = "git blame" },
      { "<leader>ga", ":Git add %<cr>", desc = "git add" },
    },
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
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "next hunk")
        map("n", "[h", gs.prev_hunk, "prev hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "undo stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "blame line")
        map("n", "<leader>ghd", gs.diffthis, "diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "diff this ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "select hunk")
      end,
    },
  },
  {
    "NeogitOrg/neogit",
    opts = { kind = "vsplit" },
    keys = {
      { "<leader>gs", neogit_open, desc = "git status" },
    },
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  },
}
