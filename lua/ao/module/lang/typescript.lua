local function organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}
	vim.lsp.buf.execute_command(params)
end

return {
	treesitter = { "typescript", "javascript" },
	only_nonels_formatting = true,
	nonels = {
		["formatting.prettier"] = {
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "templ", "svelte" },
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
