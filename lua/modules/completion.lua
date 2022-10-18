return function(use)
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")

			local t = function(str)
				return vim.api.nvim_replace_termcodes(str, true, true, true)
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				preselect = cmp.PreselectMode.None,
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<C-g>"] = cmp.mapping.abort(),
					["<Tab>"] = cmp.mapping({
						i = function(_)
							if cmp.visible() then
								cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
							elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
								vim.api.nvim_feedkeys(t("<plug>(ultisnips_jump_forward)"), "m", true)
							else
								vim.api.nvim_feedkeys(t("<tab>"), "n", true) -- fallback()
							end
						end,
					}),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
					{ name = "buffer" },
				}),
				format = function(entry, vim_item)
					if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
						vim_item.menu = entry.completion_item.detail
					else
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						vim_item.kind = require("lspkind").presets.codicons[vim_item.kind] .. "  " .. vim_item.kind
					end
					return vim_item
				end,
			})

			vim.cmd([[
				set completeopt=menuone,noinsert,noselect
				highlight! default link CmpItemKind CmpItemMenuDefault
			]])
		end,
	})
end
