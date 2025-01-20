local tbl = require("ao.tbl")
local trigger_text = ";"
local disabled_buftypes = { "prompt", "nofile" }
local disabled_filetypes = { "DressingInput" }

---@type PluginModule
return {
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"moyiz/blink-emoji.nvim",
			"folke/lazydev.nvim",
			"edte/blink-go-import.nvim",
			"saghen/blink.compat",
		},
		tag = "v0.10.0",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "enter",
				["<up>"] = { "select_prev", "fallback" },
				["<down>"] = { "select_next", "fallback" },
				["<c-k>"] = { "select_prev", "fallback" },
				["<c-j>"] = { "select_next", "fallback" },
				["<tab>"] = { "select_and_accept", "fallback" },
				["<s-tab>"] = { "select_prev", "fallback" },
			},
			enabled = function()
				return not tbl.contains(disabled_buftypes, vim.bo.buftype)
					and not tbl.contains(disabled_filetypes, vim.bo.filetype)
					and vim.b.completion ~= false
			end,
			snippets = { preset = "luasnip" },
			completion = {
				menu = {
					auto_show = true,
					border = "rounded",
					scrollbar = false,
					winhighlight = "CursorLine:CursorLine,Normal:Normal",
					winblend = 10,
				},
				documentation = {
					auto_show = true,
					window = {
						border = "rounded",
						winblend = 10,
						scrollbar = false,
						winhighlight = "CursorLine:CursorLine,Normal:Normal",
					},
				},
				list = {
					selection = {
						preselect = function(ctx)
							return ctx.mode ~= "cmdline"
						end,
						auto_insert = function(ctx)
							return ctx.mode ~= "cmdline"
						end,
					},
				},
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						score_offset = 2000,
						fallbacks = { "snippets" },
					},
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90,
						opts = {},
					},
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					snippets = {
						name = "snippets",
						enabled = true,
						max_items = 8,
						min_keyword_length = 1,
						module = "blink.cmp.sources.snippets",
						score_offset = 25,
						should_show_items = function()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
							return before_cursor:match(trigger_text .. "%w*$") ~= nil
						end,
						transform_items = function(_, items)
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
							local trigger_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
							if trigger_pos then
								for _, item in ipairs(items) do
									if not item.trigger_text_modified then
										---@diagnostic disable-next-line: inject-field
										item.trigger_text_modified = true
										item.textEdit = {
											newText = item.insertText or item.label,
											range = {
												start = { line = vim.fn.line(".") - 1, character = trigger_pos - 1 },
												["end"] = { line = vim.fn.line(".") - 1, character = col },
											},
										}
									end
								end
							end
							return items
						end,
					},
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 15,
						opts = { insert = true },
					},
					go_pkgs = {
						module = "blink-go-import",
						name = "pkgs",
					},
					buffer = {
						name = "Buffer",
						enabled = true,
						module = "blink.cmp.sources.buffer",
						should_show_items = true,
						score_offset = 50,
						opts = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
				},
				default = {
					"lazydev",
					"lsp",
					"path",
					"buffer",
					"snippets",
					"emoji",
					"go_pkgs",
					"avante_commands",
					"avante_files",
					"avante_mentions",
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
