return {
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = {},
	},
	"mattn/gist-vim",
	{
		"tpope/vim-fugitive",
		keys = {
			{ "<space>gb", ":Git blame<cr>", desc = "Git blame" },
			{ "<space>ga", ":Git add %<cr>", desc = "Git add" },
		},
	},
	"airblade/vim-gitgutter",
	{
		"NeogitOrg/neogit",
		config = {
			kind = "vsplit",
		},
		keys = {
			{ "<space>gs", ":Neogit<cr>", desc = "Git status" },
		},
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
	},
}
