-- local tbl = require("ao.tbl")
-- local trigger_text = ";"
-- local include_filetypes = { "AvanteInput" }
-- local include_buftypes = {}
-- local disabled_buftypes = { "prompt", "nofile" }
-- local disabled_filetypes = { "DressingInput" }

return {
	-- main completion engine
	{
		"hrsh7th/nvim-cmp",
		version = false,
		event = "VeryLazy",
		opts = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local luasnip = require("luasnip")

			return {
				completion = { completeopt = "menu,menuone,noinsert" },
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = {
						side_padding = 1,
						border = "rounded",
						winhighlight = "CursorLine:CursorLine,Normal:Normal",
						scrollbar = false,
					},
					documentation = {
						border = "rounded",
						winhighlight = "CursorLine:CursorLine,Normal:Normal",
						side_padding = 1,
					},
				},
				experimental = {
					ghost_text = true,
				},
				mapping = cmp.mapping.preset.insert({
					["<c-j>"] = cmp.mapping.select_next_item(),
					["<c-k>"] = cmp.mapping.select_prev_item(),
					["<c-space>"] = cmp.mapping.complete(),
					["<c-l>"] = cmp.mapping.complete({ config = { sources = { { name = "luasnip" } } } }),
					["<c-y>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<c-f>"] = cmp.mapping.scroll_docs(4),
					["<c-e>"] = cmp.mapping.close(),
					["<c-g>"] = cmp.mapping.abort(),
					["<cr>"] = cmp.mapping.confirm({ select = true }),
					["<s-cr>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<tab>"] = cmp.mapping(function(fallback)
						local col = vim.fn.col(".") - 1

						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							fallback()
						else
							cmp.complete({
								config = {
									sources = {
										{ name = "luasnip" },
									},
								},
							})
						end
					end, { "i", "s" }),
					["<s-tab>"] = cmp.mapping(function(fallback)
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "lazydev", group_index = 0 },
					{ name = "go_pkgs", group_index = 0 },
					{ name = "nvim_lsp", group_index = 1, priority = 4 },
					{ name = "path", group_index = 1, priority = 2 },
					{ name = "emoji", group_index = 1, priority = 1 },
					{
						name = "buffer",
						group_index = 2,
						option = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			}
		end,
		dependencies = {
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"Snikimonkd/cmp-go-pkgs",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-emoji",
		},
	},
}

-- blink currently disabled until dot completion is enabled: https://github.com/Saghen/blink.cmp/issues/182
-- ---@type PluginModule
-- return {
-- 	{
-- 		"saghen/blink.cmp",
-- 		event = "VeryLazy",
-- 		dependencies = {
-- 			"L3MON4D3/LuaSnip",
-- 			"moyiz/blink-emoji.nvim",
-- 			"folke/lazydev.nvim",
-- 			"edte/blink-go-import.nvim",
-- 			"saghen/blink.compat",
-- 		},
-- 		tag = "v0.10.0",
--
-- 		---@module 'blink.cmp'
-- 		---@type blink.cmp.Config
-- 		opts = {
-- 			keymap = {
-- 				preset = "enter",
-- 				["<up>"] = { "select_prev", "fallback" },
-- 				["<down>"] = { "select_next", "fallback" },
-- 				["<c-k>"] = { "select_prev", "fallback" },
-- 				["<c-j>"] = { "select_next", "fallback" },
-- 				["<tab>"] = { "select_and_accept", "fallback" },
-- 				["<s-tab>"] = { "select_prev", "fallback" },
-- 				["<m-e>"] = {
-- 					function(cmp)
-- 						cmp.show({ providers = { "emoji" } })
-- 					end,
-- 				},
-- 			},
-- 			enabled = function()
-- 				if
-- 					tbl.contains(include_filetypes, vim.bo.filetype) or tbl.contains(include_buftypes, vim.bo.buftype)
-- 				then
-- 					return true
-- 				end
-- 				return not tbl.contains(disabled_buftypes, vim.bo.buftype)
-- 					and not tbl.contains(disabled_filetypes, vim.bo.filetype)
-- 					and vim.b.completion ~= false
-- 			end,
-- 			snippets = { preset = "luasnip" },
-- 			completion = {
-- 				menu = {
-- 					auto_show = true,
-- 					border = "rounded",
-- 					scrollbar = false,
-- 					winhighlight = "CursorLine:CursorLine,Normal:Normal",
-- 					winblend = 10,
-- 				},
-- 				documentation = {
-- 					auto_show = true,
-- 					window = {
-- 						border = "rounded",
-- 						winblend = 10,
-- 						scrollbar = false,
-- 						winhighlight = "CursorLine:CursorLine,Normal:Normal",
-- 					},
-- 				},
-- 				list = {
-- 					selection = {
-- 						preselect = function(ctx)
-- 							return ctx.mode ~= "cmdline"
-- 						end,
-- 						auto_insert = function(ctx)
-- 							return ctx.mode ~= "cmdline"
-- 						end,
-- 					},
-- 				},
-- 			},
-- 			appearance = {
-- 				use_nvim_cmp_as_default = true,
-- 				nerd_font_variant = "mono",
-- 			},
-- 			sources = {
-- 				providers = {
-- 					lsp = {
-- 						name = "LSP",
-- 						module = "blink.cmp.sources.lsp",
-- 						score_offset = 2000,
-- 						fallbacks = { "snippets" },
-- 					},
-- 					avante_commands = {
-- 						name = "avante_commands",
-- 						module = "blink.compat.source",
-- 						score_offset = 90,
-- 						opts = {},
-- 					},
-- 					avante_files = {
-- 						name = "avante_files",
-- 						module = "blink.compat.source",
-- 						score_offset = 100,
-- 						opts = {},
-- 					},
-- 					avante_mentions = {
-- 						name = "avante_mentions",
-- 						module = "blink.compat.source",
-- 						score_offset = 1000,
-- 						opts = {},
-- 					},
-- 					lazydev = {
-- 						name = "LazyDev",
-- 						module = "lazydev.integrations.blink",
-- 						score_offset = 100,
-- 					},
-- 					snippets = {
-- 						name = "snippets",
-- 						enabled = true,
-- 						max_items = 8,
-- 						min_keyword_length = 1,
-- 						module = "blink.cmp.sources.snippets",
-- 						score_offset = 25,
-- 						should_show_items = function()
-- 							local col = vim.api.nvim_win_get_cursor(0)[2]
-- 							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
-- 							return before_cursor:match(trigger_text .. "%w*$") ~= nil
-- 						end,
-- 						transform_items = function(_, items)
-- 							local col = vim.api.nvim_win_get_cursor(0)[2]
-- 							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
-- 							local trigger_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
-- 							if trigger_pos then
-- 								for _, item in ipairs(items) do
-- 									if not item.trigger_text_modified then
-- 										---@diagnostic disable-next-line: inject-field
-- 										item.trigger_text_modified = true
-- 										item.textEdit = {
-- 											newText = item.insertText or item.label,
-- 											range = {
-- 												start = { line = vim.fn.line(".") - 1, character = trigger_pos - 1 },
-- 												["end"] = { line = vim.fn.line(".") - 1, character = col },
-- 											},
-- 										}
-- 									end
-- 								end
-- 							end
-- 							return items
-- 						end,
-- 					},
-- 					emoji = {
-- 						module = "blink-emoji",
-- 						name = "Emoji",
-- 						score_offset = 15,
-- 						opts = { insert = true },
-- 					},
-- 					go_pkgs = {
-- 						module = "blink-go-import",
-- 						name = "pkgs",
-- 					},
-- 					buffer = {
-- 						name = "Buffer",
-- 						enabled = true,
-- 						module = "blink.cmp.sources.buffer",
-- 						should_show_items = true,
-- 						score_offset = 50,
-- 						opts = {
-- 							get_bufnrs = function()
-- 								return vim.api.nvim_list_bufs()
-- 							end,
-- 						},
-- 					},
-- 				},
-- 				default = {
-- 					"lazydev",
-- 					"lsp",
-- 					"path",
-- 					"buffer",
-- 					"snippets",
-- 					"emoji",
-- 					"go_pkgs",
-- 					"avante_commands",
-- 					"avante_files",
-- 					"avante_mentions",
-- 				},
-- 			},
-- 		},
-- 		opts_extend = { "sources.default" },
-- 	},
-- }
