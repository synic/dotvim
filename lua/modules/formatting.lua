return function()
	return {
		{
			"jose-elias-alvarez/null-ls.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				local ns = require("null-ls")

				ns.setup({
					debug = true,
					sources = {
						-- formatting
						ns.builtins.formatting.stylua,
						ns.builtins.formatting.trim_whitespace,
						ns.builtins.formatting.prettierd,
						ns.builtins.formatting.black,

						-- completion
						ns.builtins.completion.luasnip,

						-- other
						ns.builtins.code_actions.gitsigns,
						ns.builtins.diagnostics.gitlint,
					},

					on_attach = function(client, bufnr)
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = augroup,
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({
										bufnr = bufnr,
										filter = function(c)
											return c.name == "null-ls"
										end,
									})
								end,
							})
						end
					end,
				})
			end,
		},
	}
end
