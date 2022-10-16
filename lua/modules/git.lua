return function(use)
	use("mattn/webapi-vim")
	use("mattn/gist-vim")
	use("tpope/vim-fugitive")
	use("airblade/vim-gitgutter")
	use("gregsexton/gitv")
	use({
		"TimUntersberger/neogit",
		config = function()
			local neogit = require("neogit")
			neogit.setup({
				kind = "vsplit",
			})

			vim.keymap.set("n", "<space>gs", ":Neogit<cr>")
		end,
		requires = "nvim-lua/plenary.nvim",
	})
end
