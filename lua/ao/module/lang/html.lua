return {
	treesitter = { "html", "css", "javascript", "typescript" },
	servers = {
		["emmet_language_server"] = function()
			require("lspconfig").emmet_language_server.setup({
				filetypes = {
					"css",
					"eruby",
					"html",
					"javascript",
					"javascriptreact",
					"htmldjango",
					"less",
					"sass",
					"scss",
					"svelte",
					"pug",
					"typescriptreact",
					"vue",
					"templ",
					"heex",
					"elixir",
				},
				init_options = {
					html = {
						options = {
							-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
							["bem.enabled"] = true,
						},
					},
				},
			})
		end,
	},
}
