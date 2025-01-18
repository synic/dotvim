---@type PluginModule
return {
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"moyiz/blink-emoji.nvim",
			"folke/lazydev.nvim",
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
				["<c-space>"] = {
					function(cmp)
						cmp.show({ providers = { "snippets" } })
					end,
				},

				["<c-y>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
			},
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
			},

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			sources = {
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 15,
						opts = { insert = true },
					},
				},
				default = { "lazydev", "lsp", "path", "snippets", "buffer", "emoji" },
				cmdline = {},
			},
		},
		opts_extend = { "sources.default" },
	},
}
