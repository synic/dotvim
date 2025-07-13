return {
	treesitter = { "typescript", "javascript" },
	only_nonels_formatting = true,
	nonels = {
		["formatting.prettierd"] = {
			filetypes = { "typescript", "javascript", "templ" },
		},
		["formatting.prettier"] = {
			filetypes = { "svelte" },
		},
	},
	servers = {
		["ts_ls"] = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
			root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		},
	},
}
