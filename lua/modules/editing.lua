return {
	"editorconfig/editorconfig-vim",
	"tpope/vim-surround",
	{
		"tpope/vim-commentary",
		config = function()
			vim.cmd([[
				function! ToggleComment()
					if mode() !~# "^[vV\<C-v>]"
						" not visual mode
						normal gcc
  				else
						visual gc
					endif
				endfunction

				:nmap <space>cl :call ToggleComment()<cr>
				:vmap <space>cl :call ToggleComment()<cr>
		]])
		end,
	},
	{
		"mbbill/undotree",
		keys = { "<space>tu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
	},

	{
		"p00f/nvim-ts-rainbow",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_end_of_line = true,
			})

			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",

		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
}
