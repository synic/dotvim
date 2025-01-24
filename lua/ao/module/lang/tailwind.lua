return {
	treesitter = { "css" },
	servers = {
		["tailwindcss"] = function()
			require("lspconfig").tailwindcss.setup({
				filetypes = {
					"templ",
					"astro",
					"javascript",
					"typescript",
					"react",
					"css",
					"html",
					"htmldjango",
				},
				init_options = { userLanguages = { templ = "html" } },
			})
		end,
	},
}
