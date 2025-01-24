return {
	treesitter = { "rust" },
	servers = {
		["rust_analyzer"] = function()
			require("lspconfig").rust_analyzer.setup({
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
						},
						procMacro = {
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			})
		end,
	},
}
