return {
	{ "leafgarland/typescript-vim", ft = "typescript" },
	{ "pangloss/vim-javascript", ft = "javascript" },
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "typescript", "javascript", "json" })
			end
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local lsp = require("lspconfig")

			lsp.tsserver.setup({
				filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
				cmd = { "typescript-language-server", "--stdio" },
			})
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.sources, {
				require("null-ls.builtins.formatting.prettierd"),
			})
		end,
	},
}
