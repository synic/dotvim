vim.keymap.set("n", "<space>tt", ":Telescope colorscheme<cr>")
vim.g.gruvbox_material_background = "medium"
vim.g.everforest_background = "hard"

return {
	{ "synic/jellybeans.vim", lazy = true },
	{ "jnurmine/Zenburn", lazy = true },
	{ "morhetz/gruvbox", lazy = true },
	{ "synic/synic.vim", lazy = true },
	{ "sonph/onehalf", lazy = true },
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	},
	{ "NLKNguyen/papercolor-theme", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "gosukiwi/vim-atom-dark", lazy = true },
	{ "tomasr/molokai", lazy = true },
	{ "ray-x/aurora", lazy = true },
	{ "sainnhe/sonokai", lazy = true },
	{ "folke/tokyonight.nvim" },

	{
		"vim-airline/vim-airline-themes",
		lazy = false,
		config = function()
			vim.g.airline_theme = "gruvbox_material"
		end,
	},
}
