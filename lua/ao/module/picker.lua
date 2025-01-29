local fs = require("ao.fs")
local theme = require("ao.module.theme")

local function search_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.grep({ cwd = fs.get_buffer_cwd() })
end

local function find_files_cwd()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.files({ cwd = fs.get_buffer_cwd() })
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

			-- spelling suggestions
			{ "<leader>ss", "<cmd>lua require('snacks').picker.spelling()<cr>", desc = "Spelling suggestions" },

			-- themes
			{ "<leader>st", theme.colorscheme_picker, desc = "List themes" },

			-- misc
			{ "<leader>sq", "<cmd>lua require('snacks').picker.qflist()<cr>", desc = "Search quickfix" },
			{ "<leader>su", "<cmd>lua require('snacks').picker.undo()<cr>", desc = "Undo tree" },
		},
		opts = function(_, opts)
			local snacks = require("snacks")

			return vim.tbl_deep_extend("force", {
				---@type snacks.picker.Config
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
			}, opts)
		end,
	},
}
