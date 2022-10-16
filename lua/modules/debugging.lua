return function(use)
	use("w0rp/ale")
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
			vim.keymap.set("n", "<leader>el", ":TroubleToggle<cr>")
		end,
	})
end
