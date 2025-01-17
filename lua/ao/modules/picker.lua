local utils = require("ao.utils")
local themes = require("ao.modules.themes")

local function search_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.grep({ cwd = utils.get_buffer_cwd() })
end

local function find_files_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.files({ cwd = utils.get_buffer_cwd() })
end
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
			{ "<leader>st", themes.colorscheme_picker, desc = "List themes" },

			-- misq
			{ "<leader>sq", "<cmd>lua require('snacks').picker.qflist()<cr>", desc = "Search quickfix" },
		},
		opts = {
			picker = {
				layout = {
					reverse = true,
					layout = {
						box = "horizontal",
						backdrop = false,
						width = 0.8,
						height = 0.9,
						border = "none",
						{
							box = "vertical",
							{ win = "list", title = " Results ", title_pos = "center", border = "rounded" },
							{
								win = "input",
								height = 1,
								border = "rounded",
								title = "{source} {live}",
								title_pos = "center",
							},
						},
						{
							win = "preview",
							width = 0.45,
							border = "rounded",
							title = " Preview ",
							title_pos = "center",
						},
					},
				},
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
				sources = {
					files = {
						hidden = true,
						actions = {
							switch_to_grep = function(picker, _)
								local snacks = require("snacks")
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
								local snacks = require("snacks")
								local pattern = picker.input.filter.search or picker.input.filter.pattern
								local cwd = picker.input.filter.cwd

								picker:close()

								---@diagnostic disable-next-line: missing-fields
								snacks.picker.files({ cwd = cwd, pattern = pattern })
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
		},
	},
}
