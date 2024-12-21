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
				enabled = function()
					-- Disable completion when inside a snippet
					if luasnip.in_snippet() then
						return false
					end
					local disabled = false
					disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
					disabled = disabled or (vim.fn.reg_recording() ~= "")
					disabled = disabled or (vim.fn.reg_executing() ~= "")
					return not disabled
				end,
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
					["<c-n>"] = cmp.mapping.select_next_item(),
					["<c-p>"] = cmp.mapping.select_prev_item(),
					["<c-j>"] = cmp.mapping.select_next_item(),
					["<c-k>"] = cmp.mapping.select_prev_item(),
					["<c-space>"] = cmp.mapping.complete(),
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

						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							fallback()
						else
							cmp.complete()
						end
					end, { "i", "s" }),
					["<s-tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "lazydev", group_index = 0 },
					{ name = "luasnip", group_index = 1, priority = 4 },
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
