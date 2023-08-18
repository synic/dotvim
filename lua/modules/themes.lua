vim.keymap.set("n", "<space>tt", ":Telescope colorscheme<cr>")
vim.g.gruvbox_material_background = "medium"
vim.g.everforest_background = "hard"

return {
	"synic/jellybeans.vim",
	"jnurmine/Zenburn",
	"morhetz/gruvbox",
	"synic/synic.vim",
	"sonph/onehalf",
	{
		"sainnhe/gruvbox-material",
		-- commit = "2807579bd0a9981575dbb518aa65d3206f04ea02",
		lazy = false,
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	},
	"NLKNguyen/papercolor-theme",
	"sainnhe/everforest",
	"gosukiwi/vim-atom-dark",
	"tomasr/molokai",
	"ray-x/aurora",
	"sainnhe/sonokai",

	{
		"vim-airline/vim-airline-themes",
		lazy = false,
		config = function()
			vim.g.airline_theme = "gruvbox_material"
		end,
	},
}
