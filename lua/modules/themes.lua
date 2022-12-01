vim.keymap.set("n", "<space>tt", ":Telescope colorscheme<cr>")
vim.g.gruvbox_material_background = "medium"
vim.g.everforest_background = "hard"

return function(use)
	use("synic/jellybeans.vim")
	use("jnurmine/Zenburn")
	use("morhetz/gruvbox")
	use("synic/synic.vim")
	use({
		"sonph/onehalf",
		rtp = "vim",
	})
	use({
		"sainnhe/gruvbox-material",
		commit = "2807579bd0a9981575dbb518aa65d3206f04ea02",
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	})
	use("NLKNguyen/papercolor-theme")
	use("sainnhe/everforest")
	use("gosukiwi/vim-atom-dark")
	use("tomasr/molokai")
	use("ray-x/aurora")
	use("sainnhe/sonokai")

	use({
		"vim-airline/vim-airline-themes",
		config = function()
			vim.g.airline_theme = "gruvbox_material"
		end,
	})
end
