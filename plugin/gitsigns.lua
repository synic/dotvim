vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local function gitsigns_on_attach(bufnr)
	local gs = package.loaded.gitsigns
	local keymap = require("modules.keymap")

	keymap.add({
		{ "]h", gs.next_hunk, desc = "Next hunk", buffer = bufnr },
		{ "[h", gs.prev_hunk, desc = "Prev hunk", buffer = bufnr },
		{
			"ghs",
			"<cmd>Gitsigns stage_hunk<CR>",
			desc = "Stage hunk",
			buffer = bufnr,
			mode = { "n", "v" },
		},
		{
			"ghr",
			"<cmd>Gitsigns reset_hunk<CR>",
			desc = "Reset hunk",
			buffer = bufnr,
			mode = { "n", "v" },
		},
		{ "ghS", gs.stage_buffer, desc = "Stage buffer", buffer = bufnr },
		{ "ghu", gs.undo_stage_hunk, desc = "Undo stage Hunk", buffer = bufnr },
		{ "ghR", gs.reset_buffer, desc = "Reset buffer", buffer = bufnr },
		{ "ghp", gs.preview_hunk, desc = "Preview hunk", buffer = bufnr },
		{
			"ghb",
			function()
				gs.blame_line({ full = true })
			end,
			desc = "Blame line",
			buffer = bufnr,
		},
		{ "ghd", gs.diffthis, desc = "Diff this", buffer = bufnr },
		{
			"ghD",
			function()
				gs.diffthis("~")
			end,
			desc = "Diff this ~",
			buffer = bufnr,
		},
		{
			"ih",
			"<cmd><C-U>Gitsigns select_hunk<cr>",
			desc = "Select hunk",
			buffer = bufnr,
			mode = { "o", "x" },
		},
	})
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = gitsigns_on_attach,
		})
	end,
})
