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
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-emoji",
		},
	},
}
