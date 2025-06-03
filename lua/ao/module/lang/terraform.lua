return {
	treesitter = { "terraform" },
	servers = {
		["terraform-ls"] = {
			cmd = { "terraform-lsp" },
			filetypes = { "terraform", "hcl" },
			root_markers = { ".terraform", ".git" },
		},
	},
}
