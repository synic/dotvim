return {
	-- syntax
	{ "plasticboy/vim-markdown", ft = "markdown" },
	"ap/vim-css-color",
	{ "pangloss/vim-javascript", ft = "javascript" },
	{ "leafgarland/typescript-vim", ft = "typescript" },
	{ "dart-lang/dart-vim-plugin", ft = "dart" },
	{ "jparise/vim-graphql", ft = "graphql" },

	{ "williamboman/mason.nvim", opts = {}, cmd = "Mason" },

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		lazy = false,
		opts = {
			rainbow = { enable = true },
			ensure_installed = {
				"python",
				"typescript",
				"json",
				"javascript",
				"lua",
				"yaml",
				"query",
				"sql",
				"vim",
				"bash",
				"html",
				"htmldjango",
				"markdown",
				"markdown_inline",
				"regex",
				"dart",
				"go",
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
					},
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					include_surrounding_whitespace = true,
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>a"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>A"] = "@parameter.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = { query = "@class.outer", desc = "Next class start" },
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
				lsp_interop = {
					enable = true,
					border = "none",
					peek_definition_code = {
						["<leader>df"] = "@function.outer",
						["<leader>dF"] = "@class.outer",
					},
				},
			},
		},
	},

	{ "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },

	-- python
	{ "jmcantrell/vim-virtualenv", ft = "python" },

	-- lsp
	"onsails/lspkind-nvim",
	"LuaLS/lua-language-server",
	{
		"neovim/nvim-lspconfig",
		keys = {
			{ "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to definition" },
			{ "gD", "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to definition in split" },
		},
		lazy = false,
		config = function()
			local lsp = require("lspconfig")

			-- typescript
			lsp.tsserver.setup({
				filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
				cmd = { "typescript-language-server", "--stdio" },
			})

			-- sql
			lsp.sqlls.setup({})

			-- lua
			lsp.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "hs" },
						},
					},
				},
			})

			-- python
			lsp.pylsp.setup({
				settings = {
					pylsp = {
						plugins = {
							ruff = {
								enabled = true,
								extendSelect = { "I" },
								lineLength = 120,
							},
						},
					},
				},
			})
		end,
	},
}
