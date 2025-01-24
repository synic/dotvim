vim.filetype.add({ extension = { templ = "templ" } })

return {
	treesitter = { "templ" },
	servers = {
		["templ"] = function()
			require("lspconfig").templ.setup({
				filetypes = { "templ" },
			})
		end,
	},
}
