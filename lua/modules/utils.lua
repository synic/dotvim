return function(use)
	use("vim-scripts/openssl.vim")
	use("ConradIrwin/vim-bracketed-paste")
	use({
		"s1n7ax/nvim-terminal",
		config = function()
			require("nvim-terminal").setup({
				disable_default_keymaps = true,
			})

			vim.keymap.set("n", "<space>'", ':lua NTGlobal["terminal"]:toggle()<cr>', { silent = true })
		end,
	})
	use("wakatime/vim-wakatime")
end
