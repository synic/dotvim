return {
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		opts = {},
	},
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<space>gb", ":Git blame<cr>", desc = "git blame" },
			{ "<space>ga", ":Git add %<cr>", desc = "git add" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
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
			{ "<space>gs", ":Neogit<cr>", desc = "git status" },
		},
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
	},
}
