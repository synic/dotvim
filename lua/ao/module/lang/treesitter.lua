local M = {}

M.get_plugins = function(defs)
	return {
		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			-- if you lazy load treesitter, you'll get an error when opening a lua file from the command line, even if you use
			-- the `VeryLazy` event, so do not lazy load.
			lazy = false,
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
				"nvim-treesitter/nvim-treesitter-context",
				"windwp/nvim-ts-autotag",
			},
			keys = {
				{ "<leader>t.", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
			},
			init = function()
				vim.hl = vim.highlight -- treesitter workaround
			end,
			opts = {
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
					disable = { "dart", "htmldjango" },
				},
				auto_install = true,
				ensure_installed = defs,
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						-- Disabling for dart because it was causing a few seconds of delay when creating
						-- a new line in the file.
						-- https://github.com/UserNobody14/tree-sitter-dart/issues/48
						-- https://github.com/UserNobody14/tree-sitter-dart/issues/46
						-- https://github.com/nvim-treesitter/nvim-treesitter/issues/4945
						disable = { "dart" },
						keymaps = {
							["ak"] = { query = "@block.outer", desc = "Around block" },
							["ik"] = { query = "@block.inner", desc = "Inside block" },
							["ac"] = { query = "@class.outer", desc = "Around class" },
							["ic"] = { query = "@class.inner", desc = "Inside class" },
							["a?"] = { query = "@conditional.outer", desc = "Around conditional" },
							["i?"] = { query = "@conditional.inner", desc = "Inside conditional" },
							["af"] = { query = "@function.outer", desc = "Around function" },
							["if"] = { query = "@function.inner", desc = "Inside function" },
							["al"] = { query = "@loop.outer", desc = "Around loop" },
							["il"] = { query = "@loop.inner", desc = "Inside loop" },
							["aa"] = { query = "@parameter.outer", desc = "Around argument" },
							["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@block.outer"] = "V",
							["@conditional.outer"] = "V",
							["@loop.outer"] = "V",
							["@class.outer"] = "V", -- blockwise
						},
						include_surrounding_whitespace = false,
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
						border = "rounded",
						peek_definition_code = {
							["gF"] = "@function.outer",
							["gC"] = "@class.outer",
						},
					},
				},
			},
			config = function(_, opts)
				require("nvim-treesitter.configs").setup(opts)
			end,
		},

		{
			"windwp/nvim-ts-autotag",
			lazy = true,
			opts = {
				opts = {
					enable_close = false,
					enable_rename = true,
					enable_close_on_slash = true,
				},
			},
		},
	}
end

return M
