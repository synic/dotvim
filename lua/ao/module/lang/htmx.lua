return {
	handlers = {
		["htmx"] = function()
			require("lspconfig").htmx.setup({
				filetypes = { "html", "templ", "htmldjango" },
			})
		end,
	},
}
