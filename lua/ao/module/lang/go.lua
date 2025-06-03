return {
	treesitter = { "go", "gomod", "gosum" },
	only_nonels_formatting = true,
	servers = {
		["gopls"] = {
			cmd = { "gopls" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_markers = { "go.mod", "go.work", ".git" },
			settings = {
				gopls = {
					buildFlags = { "-tags=debug,release,mage,tools" },
					completeUnimported = true,
					analyses = {
						unusedparams = true,
					},
					hints = {
						rangeVariableTypes = true,
						parameterNames = true,
						constantValues = true,
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						functionTypeParameters = true,
					},
				},
			},
		},
	},
	nonels = {
		"formatting.gofmt",
		"formatting.goimports_reviser",
		"formatting.golines",
	},
}
