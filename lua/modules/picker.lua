local M = {}

vim.api.nvim_create_user_command("Pick", function(args)
	require("snacks").picker[args.args]()
end, {
	nargs = 1,
	desc = "Snacks Picker",
})

function M.pick_window()
	local win_id = require("snacks").picker.util.pick_win({ main = vim.api.nvim_get_current_win() })

	if win_id ~= nil then
		vim.api.nvim_set_current_win(win_id)
	end
end

function M.pick_window_close()
	local win_id = require("snacks").picker.util.pick_win({ main = vim.api.nvim_get_current_win() })

	if win_id ~= nil then
		vim.api.nvim_win_close(win_id, false)
	end
end

function M.pick_undo()
	---@diagnostic disable-next-line: undefined-field
	require("snacks").picker.undo()
end

M.dir_picker = function(dir, prompt, cb)
	local proj = require("modules.project")
	local snacks = require("snacks")
	local layouts = require("snacks.picker.config.layouts")
	local entries = {}

	if type(dir) == "table" then
		entries = dir
	else
		local dirs = vim.fn.globpath(dir, "*", false, true)
		entries = {}
		for _, d in ipairs(dirs) do
			local name = string.match(d, "([^/\\]+)$")
			if name ~= nil then
				local path = d
				local entry = { name = name, path = path, text = name .. path }
				entries[#entries + 1] = entry
			end
		end
	end

	local width = 0
	local height = math.min(#entries + 5, 25)
	local max_name_length = 0
	for _, entry in ipairs(entries) do
		entry.text = entry.name .. entry.path
		max_name_length = math.max(max_name_length, #entry.name)
		local total_length = #entry.text + 22
		if total_length > width then
			width = total_length
		end
	end

	width = math.min(width, 100)
	local padding = max_name_length + 15

	snacks.picker.pick({
		items = entries,
		format = function(item, _)
			local icon, hl = snacks.util.icon(item.path, "directory")

			local padded_icon = icon:sub(-1) == " " and icon or icon .. " "
			local ret = {}
			ret[#ret + 1] = { padded_icon, hl, virtual = true }
			ret[#ret + 1] = { ":", "SnacksPickerDelim" }
			ret[#ret + 1] = { item.name, "SnacksPickerDirectory" }
			ret[#ret + 1] = { string.rep(" ", padding - #item.name), virtual = true }
			ret[#ret + 1] = { item.path, "SnacksPickerComment" }
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
						title = " " .. (prompt or "Directories") .. " ",
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
				if cb then
					cb(entry.path, entry.name)
				else
					proj.open(entry.path, entry.name)
				end
			end
		end,
		actions = {
			open_in_vsplit = function(picker, entry)
				picker:close()
				vim.cmd.vsplit(entry.path)
				proj.open(entry.path)
			end,
			open_in_split = function(picker, entry)
				picker:close()
				vim.cmd.split(entry.path)
				proj.open(entry.path)
			end,
			browse = function(picker, entry)
				picker:close()
				vim.cmd("edit! " .. entry.path)
				proj.set(entry.path)
			end,
			browse_in_vsplit = function(picker, entry)
				picker:close()
				vim.cmd("vsplit! " .. entry.path)
				proj.set(entry.path)
			end,
			browse_in_split = function(picker, entry)
				picker:close()
				vim.cmd("split! " .. entry.path)
				proj.set(entry.path)
			end,
			set_layout = function(picker, entry)
				picker:close()
				proj.set(entry.value)
				vim.notify("Project: set current layout project to " .. entry.name)
			end,
		},

		win = {
			input = {
				keys = {
					["//"] = { "open_in_vsplit", desc = "Open in vertical split", mode = { "i" } },
					["--"] = { "open_in_split", desc = "Open in horiontal split", mode = { "i" } },
					["<c-e>"] = { "browse", desc = "Open in file browser", mode = { "i" } },
					["<c-v>"] = { "browse_in_vsplit", desc = "File browser in split", mode = { "i" } },
					["<c-s>"] = { "browse_in_split", desc = "File browser in split", mode = { "i" } },
					["<c-p>"] = { "set_layout", desc = "Set layout project", mode = { "i" } },
				},
			},
		},
	})
end

return M
