vim.pack.add({
	"https://github.com/nvimtools/none-ls.nvim",
	"https://github.com/davidmh/cspell.nvim",
	"https://github.com/nvimtools/none-ls-extras.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
})

local lsp = require("modules.lsp")

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("mason").setup({})

		local nonels_sources = {}

		for source, args in pairs(lsp.nonels) do
			if type(source) == "number" then
				table.insert(nonels_sources, require("null-ls.builtins." .. args))
			else
				table.insert(nonels_sources, require("null-ls.builtins." .. source).with(args))
			end
		end

		local mason_servers = lsp.mason_servers
		require("null-ls").setup({ sources = nonels_sources })
		require("mason-lspconfig").setup({ automatic_enable = mason_servers, ensure_installed = mason_servers })
	end,
})
