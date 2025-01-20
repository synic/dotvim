vim.filetype.add({ extension = { templ = "templ" } })

return {
	treesitter = { "templ" },
	handlers = {
		["templ"] = function()
			require("lspconfig").templ.setup({
				filetypes = { "templ" },
			})
		end,
	},
}
