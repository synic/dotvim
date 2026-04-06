vim.pack.add({ "https://github.com/nanozuki/tabby.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local theme = {
			fill = "TabLineFill",
			head = "TabLineSel",
			current_tab = "TabLineSel",
			tab = "TabLine",
			tail = "TabLineSel",
		}

		require("tabby.tabline").set(function(line)
			return {
				{
					{ "  ", hl = theme.head },
					line.sep("", theme.head, theme.fill),
				},
				line.tabs().foreach(function(tab)
					local hl = tab.is_current() and theme.current_tab or theme.tab
					---@diagnostic disable-next-line: missing-fields, missing-return-value
					return {
						line.sep("", hl, theme.fill),
						tab.is_current() and "" or "󰆣",
						tab.number(),
						(require("modules.ui").get_tab_name(tab.number()) or ""),
						tab.close_btn(""),
						line.sep("", hl, theme.fill),
						hl = hl,
						margin = " ",
					}
				end),
				line.spacer(),
				{
					line.sep("", theme.tail, theme.fill),
					{ "  ", hl = theme.tail },
				},
				hl = theme.fill,
			}
		end)
	end,
})
