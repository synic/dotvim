vim.keymap.set("n", "<space>tt", ":Telescope colorscheme<cr>")

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
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	})
	use("NLKNguyen/papercolor-theme")
	use("sainnhe/everforest")
	use("gosukiwi/vim-atom-dark")
	use("tomasr/molokai")
	use("ray-x/aurora")
end
