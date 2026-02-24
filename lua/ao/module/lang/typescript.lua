return {
	treesitter = { "typescript", "javascript" },
	only_nonels_formatting = true,
	nonels = {
		["formatting.prettier"] = {
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "templ", "svelte" },
		},
	},
	servers = {
		["ts_ls"] = {},
	},
}
