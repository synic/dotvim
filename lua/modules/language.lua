return {
	-- syntax
	{ "plasticboy/vim-markdown", event = "BufEnter *.md" },
	"ap/vim-css-color",
	{ "pangloss/vim-javascript", event = "BufEnter *.js" },
	{ "leafgarland/typescript-vim", event = "BufEnter *.ts" },
	{ "dart-lang/dart-vim-plugin", event = "BufEnter *.dart" },
	{ "jparise/vim-graphql", event = "BufEnter *.graphql,*.gql" },

	{ "williamboman/mason.nvim", config = {} },

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
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
			})

			local ts_parsers = require("nvim-treesitter.parsers")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*" },
				callback = function()
					local ft = vim.bo.filetype
					if not ft then
						return
					end
					local parser = ts_parsers.filetype_to_parsername[ft]
					if not parser then
						return
					end
					local is_installed = ts_parsers.has_parser(ts_parsers.ft_to_lang(ft))
					if not is_installed then
						vim.cmd("TSInstall " .. parser)
					end
				end,
			})
		end,
	},

	"nvim-treesitter/nvim-treesitter-textobjects",

	-- python
	"jmcantrell/vim-virtualenv",

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
		end,
	},
}
