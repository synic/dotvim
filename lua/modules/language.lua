return function(use)
	-- syntax
	use("plasticboy/vim-markdown")
	use("ap/vim-css-color")
	use("pangloss/vim-javascript")
	use("dart-lang/dart-vim-plugin")

	-- python
	use("jmcantrell/vim-virtualenv")

	-- lsp
	use("onsails/lspkind-nvim")
	use({
		"neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")

			-- typescript
			lsp.tsserver.setup({
				filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
				cmd = { "typescript-language-server", "--stdio" },
			})

			-- lua
			lsp.sumneko_lua.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			-- python
			lsp.pylsp.setup({
				settings = {
					pylsp = {
						plugins = {
							flake8 = { enabled = true },
							pycodestyle = { enabled = false },
							pyflakes = { enabled = false },
							pylint = { enabled = false },
							mccabe = { enabled = false },
						},
					},
				},
			})

			vim.keymap.set("n", "gd", vim.lsp.buf.definition)
		end,
	})
	use("L3MON4D3/LuaSnip")
end
