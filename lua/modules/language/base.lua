return {
	{ "williamboman/mason.nvim", opts = {} },
	{ "williamboman/mason-lspconfig.nvim", opts = {} },

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow",
		},
		opts = {
			rainbow = { enable = true },
			ensure_installed = { "query", "vim", "regex" },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = { query = "@class.inner", desc = "select inner part of a class region" },
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
						["]]"] = { query = "@class.outer", desc = "next class start" },
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

	-- lsp
	{
		"neovim/nvim-lspconfig",
		dependencies = { "onsails/lspkind-nvim" },
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition" },
			{ "gD", "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition in split" },
			{ "<leader>r", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "rename symbol" },
		},
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			local ns = require("null-ls")

			return {
				debug = true,
				sources = {
					ns.builtins.formatting.trim_whitespace,
					ns.builtins.diagnostics.gitlint,
					ns.builtins.code_actions.gitsigns,
				},

				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									filter = function(c)
										return c.name == "null-ls"
									end,
								})
							end,
						})
					end
				end,
			}
		end,
	},
}
