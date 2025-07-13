return {
	servers = {
		arduino_language_server = {
			filetypes = { "arduino" },
			root_names = { ".git" },
			cmd = {
				"arduino-language-server",
				"-cli-config",
				vim.fn.expand("~/") .. "Library/Arduino15/arduino-cli.yaml",
			},
			capabilities = {
				textDocument = {
					semanticTokens = vim.NIL,
				},
				workspace = {
					semanticTokens = vim.NIL,
				},
			},
		},
	},
	nonels = { "formatting.astyle" },
}
