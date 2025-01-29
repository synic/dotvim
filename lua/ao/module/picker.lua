local fs = require("ao.fs")
local theme = require("ao.module.theme")

local function search_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.grep({ cwd = fs.get_buffer_cwd() })
end

local function find_files_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.smart({ cwd = fs.get_buffer_cwd() })
end

vim.api.nvim_create_user_command("Pick", function(args)
	require("snacks").picker[args.args]()
end, {
	nargs = 1,
	desc = "Snacks Picker",
})

---@type PluginModule
return {
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>gB", "<cmd>lua require('snacks').gitbrowse()<cr>", desc = "Open github in browser" },
			{ "<leader>g,", "<cmd>lua require('snacks').git.blame_line()<cr>", desc = "Blame line" },
			{ "<leader>:", "<cmd>lua require('snacks').scratch()<cr>", desc = "Scratch Buffers" },
			{ "<leader>^", "<cmd>lua require('snacks').dashboard()<cr>", desc = "Dashboard" },
			{
				"<leader>sn",
				"<cmd>lua require('snacks').notifier.show_history()<cr>",
				desc = "Show notification history",
			},

			{ "<leader>sd", search_cwd, desc = "Search in buffer's directory" },
			{ "<leader>sR", "<cmd>lua require('snacks').picker.registers()<cr>", desc = "Registers" },
			{ "<leader>sl", "<cmd>lua require('snacks').picker.marks()<cr>", desc = "Marks" },
			{ "<leader>sB", "<cmd>lua require('snacks').picker.pickers()<cr>", desc = "List pickers" },
			{ "<leader>sb", "<cmd>lua require('snacks').picker.lines()<cr>", desc = "Search buffer" },
			{ "<leader>.", "<cmd>lua require('snacks').picker.resume()<cr>", desc = "Resume last search" },

			-- buffers
			{ "<leader>bb", "<cmd>lua require('snacks').picker.buffers()<cr>", desc = "Show buffers" },

			-- files
			{ "<leader>ff", find_files_cwd, desc = "Find files" },
			{ "<leader>fr", "<cmd>lua require('snacks').picker.recent()<cr>", desc = "Recent files" },
			{ "<leader>fs", search_cwd, desc = "Search files in current dir" },

			-- themes
			{ "<leader>st", theme.colorscheme_picker, desc = "List themes" },

			-- misc
			{ "<leader>sq", "<cmd>lua require('snacks').picker.qflist()<cr>", desc = "Search quickfix" },
			{ "<leader>su", "<cmd>lua require('snacks').picker.undo()<cr>", desc = "Undo tree" },
		},
		opts = function(_, opts)
			local snacks = require("snacks")
			local layouts = require("snacks.picker.config.layouts")
			return vim.tbl_deep_extend("force", {
				---@type snacks.picker.Config
				picker = {
					main = {
						current = true,
					},
					layout = layouts.telescope,
					ui_select = false, -- dressing.nvim does a good implementation, so use that
					actions = {
						flash_jump = function(picker)
							local has_flash, flash = pcall(require, "flash")

							if has_flash then
								---@diagnostic disable-next-line: missing-fields
								flash.jump({
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
										local list = picker.list
										vim.api.nvim_win_set_cursor(list.win.win, { match.pos[1], 0 })
										local idx = list:row2idx(match.pos[1])
										list:_move(idx, true, true)
									end,
								})
							else
								vim.notify("flash.nvim not installed", vim.log.levels.WARN)
							end
						end,
					},
					win = {
						input = {
							keys = {
								["//"] = { "edit_vsplit", desc = "Edit in vertical split", mode = { "i" } },
								["--"] = { "edit_split", desc = "Edit in horizontal split", mode = { "i" } },
								["<a-s>"] = { "flash_jump", desc = "Jump to entry", mode = { "i" } },
							},
						},
					},
					formatters = {
						text = {
							ft = nil, ---@type string? filetype for highlighting
						},
						file = {
							filename_first = false,
							truncate = 200,
							filename_only = false,
						},
						selected = {
							show_always = false,
							unselected = true,
						},
					},
					sources = {
						smart = {
							hidden = true,
							actions = {
								switch_to_grep = function(picker, _)
									local pattern = picker.input.filter.pattern or picker.input.filter.search
									local cwd = picker.input.filter.cwd

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
									snacks.picker.smart({ cwd = cwd, pattern = pattern })
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
