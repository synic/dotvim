return function(use)
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
		config = function()
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			require("null-ls").setup({
				debug = true,
				sources = {
					-- formatting
					require("null-ls").builtins.formatting.stylua,
					require("null-ls").builtins.formatting.trim_whitespace,
					require("null-ls").builtins.formatting.prettierd,
					require("null-ls").builtins.formatting.black,

					-- diagnostics
					require("null-ls").builtins.diagnostics.eslint,

					-- completion
					require("null-ls").builtins.completion.luasnip,
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
	})
end
