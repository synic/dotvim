local function commentary_toggle()
	if vim.api.nvim_get_mode().mode == "n" then
		vim.cmd("normal gcc")
	else
		vim.cmd("visual gc")
	end
end

return {

	{
		"Lokaltog/vim-easymotion",
		init = function()
			vim.g.EasyMotion_smartcase = true
		end,
		keys = {
			{ "<space><space>", "<plug>(easymotion-overwin-f)", desc = "jump to location" },
		},
	},
	"editorconfig/editorconfig-vim",
	"tpope/vim-surround",
	{
		"tpope/vim-commentary",
		keys = {
			{ "<leader>c", commentary_toggle, desc = "toggle comments", { mode = "v" } },
		},
	},
	{
		"mbbill/undotree",
		keys = { "<space>tu", "<cmd>UndotreeToggle<cr>", desc = "undo tree" },
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
