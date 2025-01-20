local function setup_tsserver()
	require("lspconfig").ts_ls.setup({
		filetypes = { "templ", "javascript", "typescript", "html" },
	})
end

return {
	treesitter = { "typescript", "javascript" },
	handlers = {
		["ts_ls"] = setup_tsserver,
		["tsserver"] = setup_tsserver,
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
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			config = true,
		},
	},
}
