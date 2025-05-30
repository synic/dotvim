local M = { plugins = {} }

function M.pick()
	local snacks = require("snacks")
	local ui = require("ao.module.ui")
	local layouts = require("snacks.picker.config.layouts")
	local entries = {}

	-- Get all layouts (tabs)
	local tabs = vim.api.nvim_list_tabpages()
	for _, tab in ipairs(tabs) do
		local tabnr = vim.api.nvim_tabpage_get_number(tab)
		local tab_name = ui.get_tab_name(tabnr)
		local display_name = tostring(tabnr) .. ": " .. (tab_name or "unknown")

		entries[#entries + 1] = {
			text = display_name,
			name = display_name,
			tabnr = tabnr,
			tab = tab,
		}
	end

	-- Sort by tab number
	table.sort(entries, function(a, b)
		return a.tabnr < b.tabnr
	end)

	local width = 80
	local height = math.min(#entries + 5, 17)

	snacks.picker.pick({
		items = entries,
		format = function(item, _)
			local ret = {}
			ret[#ret + 1] = { "󰓩 ", "SnacksPickerIcon" }
			ret[#ret + 1] = { item.name, "SnacksPickerDirectory" }
			return ret
		end,
		layout = vim.tbl_deep_extend("force", layouts.telescope, {
			layout = {
				width = width,
				height = height,
				{
					box = "vertical",
					{
						win = "list",
						title = " Layouts ",
						title_pos = "center",
						border = "rounded",
					},
					{ win = "input", height = 1, border = "rounded", title = "{source} {live}", title_pos = "center" },
				},
			},
			preview = false,
		}),
		confirm = function(picker, entry)
			picker:close()
			if entry then
				vim.api.nvim_set_current_tabpage(entry.tab)
			end
		end,
	})
end

function M.set_name()
	---@diagnostic disable-next-line: missing-fields
	vim.ui.input({ prompt = "layout name: ", default = (vim.t.layout_name or "") }, function(name)
		if name then
			---@diagnostic disable-next-line: inject-field
			vim.t.layout_name = name
			vim.cmd.redrawtabline()
		end
	end)
end

return M
