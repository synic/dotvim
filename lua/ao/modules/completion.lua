return {
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"moyiz/blink-emoji.nvim",
		},
		tag = "v0.10.0",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "enter",
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<c-k>"] = { "select_prev", "fallback" },
				["<c-j>"] = { "select_next", "fallback" },
				["<C-space>"] = {
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
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 15,
						opts = { insert = true },
					},
				},
				default = { "lsp", "path", "snippets", "buffer", "emoji" },
				cmdline = {},
			},
		},
		opts_extend = { "sources.default" },
	},
}
