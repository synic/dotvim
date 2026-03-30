return {
	treesitter = { "go", "gomod", "gosum" },
	format_on_save = "nonels",
	servers = {
		["gopls"] = {
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
