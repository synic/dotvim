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
				["<tab>"] = { "select_and_accept", "fallback" },
				["<s-tab>"] = { "select_prev", "fallback" },

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
			enabled = function()
				return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
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
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
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
				},
				default = {
					"lazydev",
					"lsp",
					"path",
					"buffer",
					"snippets",
					"emoji",
					"go_pkgs",
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
