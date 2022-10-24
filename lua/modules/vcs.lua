return function(use)
	use({
		"akinsho/git-conflict.nvim",
		tag = "*",
		config = function()
			require("git-conflict").setup()
		end,
	})
	use("mattn/gist-vim")
	use({
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<space>gb", ":Git blame<cr>")
			vim.keymap.set("n", "<space>ga", ":Git add %<cr>")
		end,
	})
	use("airblade/vim-gitgutter")
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
