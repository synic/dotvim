return {
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = function()
			require("git-conflict").setup()
		end,
	},
	"mattn/gist-vim",
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<space>gb", ":Git blame<cr>")
			vim.keymap.set("n", "<space>ga", ":Git add %<cr>")
		end,
	},
	"airblade/vim-gitgutter",
	{
		"NeogitOrg/neogit",
		config = function()
			local neogit = require("neogit")
			neogit.setup({
				kind = "vsplit",
			})

			vim.keymap.set("n", "<space>gs", ":Neogit<cr>")
		end,
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
	},
}
