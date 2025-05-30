return {
	treesitter = { "go", "gomod", "gosum" },
	only_nonels_formatting = true,
	servers = {
		["gopls"] = function()
			require("lspconfig").gopls.setup({
				cmd = { "/Users/synic/.go/bin/gopls" },
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
