local ok, nvim_lsp = pcall(require, "lspconfig")
if not ok then
	return
end

-- TypeScript
nvim_lsp.tsserver.setup({
	filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
	cmd = { "typescript-language-server", "--stdio" },
})

-- Lua
nvim_lsp.sumneko_lua.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
