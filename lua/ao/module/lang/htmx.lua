return {
	servers = {
		["htmx"] = function()
			require("lspconfig").htmx.setup({
				filetypes = { "html", "templ", "htmldjango" },
			})
		end,
	},
}
