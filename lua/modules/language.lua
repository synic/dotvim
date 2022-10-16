return function(use)
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
	use("tpope/vim-surround")
	use("w0rp/ale")
	use("jmcantrell/vim-virtualenv")
	use("editorconfig/editorconfig-vim")
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
			vim.keymap.set("n", "<space>el", ":TroubleToggle<cr>")
		end,
	})
end
