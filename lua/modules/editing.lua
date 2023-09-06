return {

	{
		"Lokaltog/vim-easymotion",
		init = function()
			vim.g.EasyMotion_smartcase = true
		end,
		keys = {
			{ "<space><space>", "<plug>(easymotion-overwin-f)", desc = "jump to location" },
			{ "<space><space>", "<plug>(easymotion-bd-f)", mode = { "v" }, desc = "jump to location" },
		},
	},
	"editorconfig/editorconfig-vim",
	"tpope/vim-surround",
	{
		"tpope/vim-commentary",
		keys = {
			{ "<leader>c", "<plug>Commentary", mode = "v", desc = "toggle comment" },
			{ "<leader>c", "<plug>CommentaryLine", desc = "toggle comment" },
		},
	},
	{
		"mbbill/undotree",
		keys = { { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "undo tree" } },
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
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
}
