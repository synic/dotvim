return {
	treesitter = { "typescript", "javascript" },
	handlers = {
		["ts_ls"] = function()
			require("lspconfig").ts_ls.setup({
				filetypes = { "templ", "javascript", "typescript", "html" },
			})
		end,
	},
	nonels = {
		["formatting.prettierd"] = {
			filetypes = { "typescript", "javascript", "templ" },
		},
		["formatting.prettier"] = {
			filetypes = { "svelte" },
		},
	},
	plugins = {
		{
			"pmizio/typescript-tools.nvim",
			ft = { "typescript", "javascript" },
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			config = true,
		},
	},
}
