local fs = require("ao.fs")
local theme = require("ao.module.theme")
local M = {}

local function search_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.grep({ cwd = fs.get_buffer_cwd() })
end

local function find_files_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.files({ cwd = fs.get_buffer_cwd() })
end

local function pick_window()
	local win_id = require("snacks").picker.util.pick_win()

	if win_id ~= nil then
		vim.api.nvim_set_current_win(win_id)
	end
end

local function pick_window_close()
	local win_id = require("snacks").picker.util.pick_win()

	if win_id ~= nil then
		vim.api.nvim_win_close(win_id, false)
	end
end

vim.api.nvim_create_user_command("Pick", function(args)
	require("snacks").picker[args.args]()
end, {
	nargs = 1,
	desc = "Snacks Picker",
})

local function pick_undo()
	-- close avante if it's open because it breaks with this picker open for some reason
	local ok, avante = pcall(require, "avante")
	if ok then
		local sidebar = avante.get()
		if sidebar ~= nil then
			sidebar:close()
		end
	end
	---@diagnostic disable-next-line: undefined-field
	require("snacks").picker.undo()
end

M.dir_picker = function(dir, prompt, cb)
	local proj = require("ao.module.proj")
	local snacks = require("snacks")
	local layouts = require("snacks.picker.config.layouts")
	local entries = {}

	if type(dir) == "table" then
		entries = dir
	else
		local dirs = vim.fn.globpath(dir, "*", false, 1)
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
			local padded_icon = icon .. " "

			local ret = {}
			ret[#ret + 1] = { padded_icon, hl, virtual = true }
			ret[#ret + 1] = { item.name, "SnacksPickerFile" }
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
					cb(entry.path)
				else
					proj.open(entry.path)
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

---@type PluginModule
M.plugins = {
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>sd", search_cwd, desc = "Search in buffer's directory" },
			{ "<leader>sR", "<cmd>lua require('snacks').picker.registers()<cr>", desc = "Registers" },
			{ "<leader>sl", "<cmd>lua require('snacks').picker.marks()<cr>", desc = "Marks" },
			{ "<leader>sB", "<cmd>lua require('snacks').picker.pickers()<cr>", desc = "List pickers" },
			{ "<leader>sb", "<cmd>lua require('snacks').picker.lines()<cr>", desc = "Search buffer" },
			{ "<leader>.", "<cmd>lua require('snacks').picker.resume()<cr>", desc = "Resume last search" },

			-- buffers
			{ "<leader>bb", "<cmd>lua require('snacks').picker.buffers()<cr>", desc = "Show buffers" },

			-- files
			{ "<leader>fe", "<cmd>lua require('snacks').picker.explorer()<cr>", desc = "File explorer" },
			{ "<leader>ff", find_files_cwd, desc = "Find files" },
			{ "<leader>fr", "<cmd>lua require('snacks').picker.recent()<cr>", desc = "Recent files" },
			{ "<leader>fs", search_cwd, desc = "Search files in current dir" },
			{ "<leader>,", "<cmd>lua require('snacks').picker.smart()<cr>", desc = "Smart Picker" },

			-- spelling suggestions
			{ "<leader>ss", "<cmd>lua require('snacks').picker.spelling()<cr>", desc = "Spelling suggestions" },

			-- themes
			{ "<leader>st", theme.colorscheme_picker, desc = "List themes" },

			-- windows
			{ "<leader>w<leader>", pick_window, desc = "Jump to window" },
			{ "<leader>wC", pick_window_close, desc = "Pick window to close" },

			-- misc
			{ "<leader>sq", "<cmd>lua require('snacks').picker.qflist()<cr>", desc = "Search quickfix" },
			{ "<leader>su", pick_undo, desc = "Undo tree" },
		},
		opts = function(_, opts)
			local snacks = require("snacks")
			local last_picker = "files"

			return vim.tbl_deep_extend("force", {
				---@type snacks.picker.Config
				---@diagnostic disable-next-line: missing-fields
				picker = {
					main = { current = true },
					layout = { preset = "telescope" },
					ui_select = true,
					actions = {
						flash = function(picker)
							---@diagnostic disable-next-line: missing-fields
							require("flash").jump({
								pattern = "^",
								label = { after = { 0, 0 } },
								search = {
									mode = "search",
									exclude = {
										function(win)
											return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
												~= "snacks_picker_list"
										end,
									},
								},
								action = function(match)
									local idx = picker.list:row2idx(match.pos[1])
									picker.list:_move(idx, true, true)
								end,
							})
						end,
					},
					win = {
						input = {
							keys = {
								["//"] = { "edit_vsplit", desc = "Edit in vertical split", mode = { "i" } },
								["--"] = { "edit_split", desc = "Edit in horizontal split", mode = { "i" } },
								["<a-s>"] = { "flash", mode = { "n", "i" } },
								["s"] = { "flash" },
							},
						},
					},
					formatters = { file = { truncate = 200 } },
					sources = {
						select = { layout = { preset = "select" } },
						files = {
							hidden = true,
							actions = {
								switch_to_grep = function(picker, _)
									local pattern = picker.input.filter.pattern or picker.input.filter.search
									local cwd = picker.input.filter.cwd
									last_picker = "files"

									picker:close()

									---@diagnostic disable-next-line: missing-fields
									snacks.picker.grep({ cwd = cwd, search = pattern })
								end,
							},
							win = {
								input = {
									keys = {
										["<a-r>"] = { "switch_to_grep", desc = "Switch to grep", mode = { "i", "n" } },
									},
								},
							},
						},
						smart = {
							hidden = true,
							actions = {
								switch_to_grep = function(picker, _)
									local pattern = picker.input.filter.pattern or picker.input.filter.search
									local cwd = picker.input.filter.cwd
									last_picker = "smart"

									picker:close()

									---@diagnostic disable-next-line: missing-fields
									snacks.picker.grep({ cwd = cwd, search = pattern })
								end,
							},
							win = {
								input = {
									keys = {
										["<a-r>"] = { "switch_to_grep", desc = "Switch to grep", mode = { "i", "n" } },
									},
								},
							},
						},
						grep = {
							actions = {
								switch_to_files = function(picker, _)
									local pattern = picker.input.filter.search or picker.input.filter.pattern
									local cwd = picker.input.filter.cwd

									picker:close()

									---@diagnostic disable-next-line: missing-fields
									snacks.picker[last_picker]({ cwd = cwd, pattern = pattern })
								end,
							},
							win = {
								input = {
									keys = {
										["<a-r>"] = { "switch_to_files", desc = "Switch to files", mode = { "i", "n" } },
									},
								},
							},
						},
					},
				},
			}, opts)
		end,
	},
}

return M
