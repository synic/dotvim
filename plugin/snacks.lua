vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

local notification_width = 70
local last_picker = "files"

local disable_scope_filetypes = {
	"help",
	"alpha",
	"dashboard",
	"snacks_dashboard",
	"neo-tree",
	"Trouble",
	"snacks_picker_list",
	"Avante",
	"trouble",
	"lazy",
	"mason",
	"notify",
	"toggleterm",
	"lazyterm",
}

local notifier_ignore_messages = {
	"No information available",
	"%[oil%] could not find adapter for buffer",
	"Could not find oil adapter for scheme",
}

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local config = require("modules.config")
		local proj = require("modules.project")
		local snacks = require("snacks")
		local a = require("snacks.picker.util").align
		local fmt = require("snacks.picker.format")

		require("snacks").setup({
			picker = {
				main = { current = true },
				layout = { preset = "telescope" },
				ui_select = true,
				win = {
					input = {
						keys = {
							["//"] = { "edit_vsplit", desc = "Edit in vertical split", mode = { "i" } },
							["--"] = { "edit_split", desc = "Edit in horizontal split", mode = { "i" } },
							["<a-a>"] = { "send_to_ai", desc = "Send paths to AI", mode = { "n", "i" } },
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
					buffers = {
						format = function(item, picker)
							local mod = vim.bo[item.buf] and vim.bo[item.buf].modified
							local ret = {}

							ret[#ret + 1] = { a(tostring(item.buf), 3), "SnacksPickerBufNr" }
							ret[#ret + 1] = {
								a(mod and "●" or " ", 2),
								mod and "SnacksPickerBufModified" or "SnacksPickerDimmed",
							}
							ret[#ret + 1] = { a(item.flags, 2, { align = "right" }), "SnacksPickerBufFlags" }
							ret[#ret + 1] = { " " }

							vim.list_extend(ret, fmt.filename(item, picker))
							return ret
						end,
					},
				},
			},
			dashboard = {
				enabled = true,
				preset = {
					pick = nil,
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
						},
						{
							icon = " ",
							key = "s",
							desc = "Restore Session",
							action = function()
								require("modules.session").restore_session()
							end,
						},
						{
							icon = "󰒲 ",
							key = "L",
							desc = "Lazy",
							action = ":Lazy",
							enabled = package.loaded.lazy ~= nil,
						},
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
					header = header,
				},
				sections = {
					{ section = "header" },

					{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{
						icon = " ",
						title = "Projects",
						section = "projects",
						limit = 7,
						indent = 2,
						padding = 1,
						action = function(dir)
							proj.open(dir)
						end,
						dirs = function()
							local cwd = config.options.projects.directory.path or "."
							local project_entries = proj.list({ cwd = cwd })
							local dirs = {}

							for _, entry in ipairs(project_entries) do
								dirs[#dirs + 1] = entry.path
							end

							return dirs
						end,
					},
				},
			},
			indent = {
				indent = { enabled = false },
				scope = { char = "╎", only_current = true },
				filter = function(buf)
					---@diagnostic disable-next-line: undefined-field
					return vim.g.snacks_indent ~= false
						and vim.b[buf].snacks_indent ~= false
						and not vim.tbl_contains(disable_scope_filetypes, vim.bo[buf].filetype)
						and vim.bo[buf].buftype == ""
				end,
			},
			scope = {},
			---@type snacks.notifier.Config
			---@diagnostic disable-next-line: missing-fields
			notifier = {
				top_down = false,
				width = { min = notification_width, max = notification_width },
				margin = { top = 0, right = 1, bottom = 1 },
				filter = function(notif)
					for _, m in ipairs(notifier_ignore_messages) do
						if notif.msg:match("^" .. m) then
							return false
						end
					end

					return true
				end,
			},
			git = { enabled = true },
			gitbrowse = { enabled = true },
			scratch = { enabled = true },
			styles = {
				terminal = {
					bo = {
						filetype = "snacks_terminal",
					},
					wo = {},
					keys = {
						q = "hide",
						["<c-x>"] = "hide",
						gf = function(self)
							local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
							if f == "" then
								Snacks.notify.warn("No file under cursor")
							else
								self:hide()
								vim.schedule(function()
									vim.cmd("e " .. f)
								end)
							end
						end,

						["<leader>ac"] = "hide",
						term_normal = {
							"<c-g>",
							function(_)
								vim.cmd("stopinsert")
							end,
							mode = "t",
							expr = true,
							desc = "Escape to normal mode",
						},
					},
				},
			},
		})
	end,
})
