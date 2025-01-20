return {
	treesitter = { "go", "gomod", "gosum" },
	handlers = {
		["gopls"] = function()
			require("lspconfig").gopls.setup({
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
			})
		end,
	},
	nonels = {
		"formatting.gofmt",
		"formatting.goimports_reviser",
		"formatting.golines",
	},
}
