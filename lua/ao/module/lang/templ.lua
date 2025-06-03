vim.filetype.add({ extension = { templ = "templ" } })

return {
	servers = {
		["templ"] = {
			cmd = { "templ", "lsp" },
			filetypes = { "templ" },
			root_markers = { "go.work", "go.mod", ".git" },
		},
	},
}
