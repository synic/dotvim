---@diagnostic disable: inject-field
local config = require("ao.config")
local utils = require("ao.utils")
local projects = require("ao.modules.projects")

local clear_winbar_group = vim.api.nvim_create_augroup("WinBarHlClearBg", { clear = true })
local indentscope_disable_group = vim.api.nvim_create_augroup("MiniIndentScopeDisable", { clear = true })

local M = {}

function M.buffer_show_path(full)
	local pattern = "%p"

	if full then
		pattern = "%:p"
	end

	local path = vim.fn.expand(pattern)
	vim.fn.setreg("+", path)
	vim.notify(path)
	vim.print(path)
end

function M.buffer_show_full_path()
	M.buffer_show_path(true)
end

-- excluding the current window, move all cursors to 0 position on their current line
-- for all windows in the current tab
function M.zero_window_cursors(tabnr, exclude_current)
	local current = vim.fn.winnr()

	for nr, _ in ipairs(vim.api.nvim_tabpage_list_wins(tabnr or 0)) do
		if current ~= nr or not exclude_current then
			vim.cmd(nr .. "windo norm 0")
		end
	end

	vim.cmd(current .. "windo normal! m'")
end

function M.zero_all_window_cursors(tabnr)
	M.zero_window_cursors(tabnr, true)
end

-- Execute a command across all tabs
function M.tabdo(cmd)
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("tabdo " .. cmd)
	vim.cmd(current_tab .. "tabnext") -- restore original tab position
end

-- Equalize windows in all tabs
function M.equalize_all_tabs()
	M.tabdo("wincmd =")
end

function M.quickfix_remove_item_move_next()
	vim.cmd.copen()
	local curqfidx = vim.fn.line(".")
	local qfall = vim.fn.getqflist()

	if #qfall == 0 then
		return
	end

	table.remove(qfall, curqfidx)
	vim.fn.setqflist(qfall, "r")

	local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)
	vim.api.nvim_win_set_cursor(vim.fn.win_getid(), { new_idx, 0 })
	vim.cmd("cc" .. new_idx)
end

function M.layout_set_name()
	---@diagnostic disable-next-line: missing-fields
	vim.ui.input({ prompt = "layout name: ", default = (vim.t.layout_name or "") }, function(name)
		if name then
			vim.t.layout_name = name
			vim.cmd.redrawtabline()
		end
	end)
end

function M.goto_lazy_dir()
	local path = vim.fn.resolve(vim.fn.stdpath("data") .. "/" .. "lazy")
	vim.cmd.edit(path)
end

function M.goto_dotfiles_dir()
	vim.cmd.edit(vim.fn.expand("~/.dotfiles"))
end

local function lualine_trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
	return function(str)
		local win_width = vim.fn.winwidth(0)
		if hide_width and win_width < hide_width then
			return ""
		elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
			return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
		end
		return str
	end
end

local function golden_ratio_toggle()
	vim.cmd.GoldenRatioToggle()
	if vim.g.golden_ratio_enabled == 0 then
		vim.g.golden_ratio_enabled = 1
		vim.notify("Golden Ratio: enabled")
	else
		vim.g.golden_ratio_enabled = 0
		vim.notify("Golden Ratio: disabled")
		vim.g.equalalways = true
		M.equalize_all_tabs()
	end
end

function M.get_tab_name(tabnr)
	return projects.get_name(tabnr)
end

M.plugin_specs = {
	-- extensible core UI hooks
	{ "stevearc/dressing.nvim", config = true, event = "VeryLazy" },

	-- notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		opts = {
			render = "minimal",
			stages = "fade",
			timeout = 1000,
			top_down = false,
			max_width = 100,
			max_height = 10,
		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup(opts)
			local banned_messages = { "No information available" }
			---@diagnostic disable-next-line: duplicate-set-field
			vim.notify = function(msg, ...)
				for _, banned in ipairs(banned_messages) do
					if msg == banned then
						return
					end
				end
				return notify(msg, ...)
			end
		end,
	},

	-- show indent scope
	{
		"echasnovski/mini.indentscope",
		event = "VeryLazy",
		version = false,
		config = true,
		init = function()
			local disable_for = {
				"help",
				"alpha",
				"dashboard",
				"snacks_dashboard",
				"neo-tree",
				"Trouble",
				"Avante",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			}

			-- for lazy loading into an existing file
			if utils.table_contains(disable_for, vim.bo.filetype) or vim.api.nvim_buf_get_name(0) == "" then
				vim.b.miniindentscope_disable = true
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = disable_for,
				group = indentscope_disable_group,
				callback = function()
					---@diagnostic disable-next-line: inject-field
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- various interface and vim scripting utilities
	{
		"tpope/vim-scriptease",
		keys = {
			{ "<leader>sm", "<cmd>Messages<cr>", desc = "Messages" },
		},
	},

	-- highlight css and other colors
	{
		"norcalli/nvim-colorizer.lua",
		name = "colorizer",
		opts = {
			"javascript",
			"css",
			"html",
			"templ",
			"sass",
			"scss",
			"typescript",
			"json",
			"lua",
		},
	},

	-- show marks in gutter
	{ "kshenoy/vim-signature", event = "VeryLazy" },

	{
		"Bekaboo/dropbar.nvim",
		event = "VeryLazy",
		keys = {
			{ "<localleader>.", "<cmd>lua require('dropbar.api').pick()<cr>", desc = "Breadcrumb picker" },
		},
		opts = function()
			local dutils = require("dropbar.utils")
			local preview = false
			local ignore = { "gitcommit" }
			return {
				bar = {
					enable = function(buf, win)
						return vim.fn.win_gettype(win) == ""
							and vim.wo[win].winbar == ""
							and vim.bo[buf].bt == ""
							and not utils.table_contains(ignore, vim.bo[buf].ft)
							and (
								vim.bo[buf].ft == "markdown"
								or (
									buf
										and vim.api.nvim_buf_is_valid(buf)
										and (pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft))
										and true
									or false
								)
							)
					end,
				},
				menu = {
					preview = preview,
					keymaps = {
						["q"] = "<C-w>q",
						["h"] = "<C-w>q",
						["<LeftMouse>"] = function()
							local menu = dutils.menu.get_current()
							if not menu then
								return
							end
							local mouse = vim.fn.getmousepos()
							---@diagnostic disable-next-line: undefined-field
							local clicked_menu = dutils.menu.get({ win = mouse.winid })
							-- If clicked on a menu, invoke the corresponding click action,
							-- else close all menus and set the cursor to the clicked window
							if clicked_menu then
								clicked_menu:click_at({
									---@diagnostic disable-next-line: undefined-field
									mouse.line,
									---@diagnostic disable-next-line: undefined-field
									mouse.column - 1,
								}, nil, 1, "l")
								return
							end
							dutils.menu.exec("close")
							dutils.bar.exec("update_current_context_hl")
							---@diagnostic disable-next-line: undefined-field
							if vim.api.nvim_win_is_valid(mouse.winid) then
								---@diagnostic disable-next-line: undefined-field
								vim.api.nvim_set_current_win(mouse.winid)
							end
						end,
						["l"] = function()
							local menu = dutils.menu.get_current()
							if not menu then
								return
							end
							local cursor = vim.api.nvim_win_get_cursor(menu.win)
							local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
							if component then
								menu:click_on(component, nil, 1, "l")
							end
						end,
						["<MouseMove>"] = function()
							local menu = dutils.menu.get_current()
							if not menu then
								return
							end
							local mouse = vim.fn.getmousepos()
							dutils.menu.update_hover_hl(mouse)
							if preview then
								dutils.menu.update_preview(mouse)
							end
						end,
						["i"] = function()
							local menu = dutils.menu.get_current()
							if not menu then
								return
							end
							menu:fuzzy_find_open()
						end,
					},
				},
			}
		end,
		config = function(_, opts)
			---Set WinBar & WinBarNC background to Normal background
			---@return nil
			local function clear_winbar_bg()
				---@param name string
				---@return nil
				local function _clear_bg(name)
					local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
					if hl.bg or hl.ctermbg then
						hl.bg = nil
						---@diagnostic disable-next-line: undefined-field, inject-field
						hl.ctermbg = nil
						---@diagnostic disable-next-line: param-type-mismatch
						vim.api.nvim_set_hl(0, name, hl)
					end
				end

				_clear_bg("WinBar")
				_clear_bg("WinBarNC")
			end

			clear_winbar_bg()

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = clear_winbar_group,
				callback = clear_winbar_bg,
			})

			require("dropbar").setup(opts)
		end,
	},

	-- fancy up those tabs
	{
		"nanozuki/tabby.nvim",
		event = "TabEnter",
		config = function()
			local theme = {
				fill = "TabLineFill",
				head = "TabLine",
				current_tab = "TabLineSel",
				tab = "TabLine",
				win = "TabLine",
				tail = "TabLine",
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
							(M.get_tab_name(tab.number()) or ""),
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
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		init = function()
			vim.o.laststatus = 3
		end,
		opts = function()
			local lualine_utils = require("lualine.utils.utils")

			local function repo_name(_, is_focused)
				if not is_focused then
					return ""
				end

				local path = projects.find_buffer_root()
				return lualine_utils.stl_escape(vim.fs.basename(path or ""))
			end

			return {
				options = {
					component_separators = "|",
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_b = {
						{ repo_name, icon = "" },
						{ "diff" },
						{ "diagnostics" },
					},
					lualine_c = {
						{ "filename", file_status = true, path = 1 },
					},
					lualine_x = {
						{ "encoding", fmt = lualine_trunc(0, 0, 120) },
						{ "fileformat", fmt = lualine_trunc(0, 0, 120) },
						{ "filetype", fmt = lualine_trunc(0, 0, 120) },
					},
					lualine_y = {
						{ "progress", fmt = lualine_trunc(0, 0, 100) },
					},
				},
				inactive_sections = {
					lualine_c = {
						{ "filename", file_status = true, path = 1 },
					},
				},
			}
		end,
	},

	-- snacks
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>gB", "<cmd>lua require('snacks').gitbrowse()<cr>", desc = "Open github in browser" },
			{ "<leader>g,", "<cmd>lua require('snacks').git.blame_line()<cr>", desc = "Blame line" },
			{ "<leader>:", "<cmd>lua require('snacks').scratch()<cr>", desc = "Scratch Buffers" },
			{ "<leader>^", "<cmd>lua require('snacks').dashboard()<cr>", desc = "Dashboard" },
		},
		opts = {
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
							action = ":lua require('persistence').load({ last=true })",
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
					header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
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
							require("ao.modules.projects").open(dir)
						end,
						dirs = function()
							local cwd = config.options.projects.directory.path or "."
							local project_entries = projects.list({ cwd = cwd })
							local dirs = {}

							for _, entry in ipairs(project_entries) do
								if type(entry) == "table" then
									entry = entry.path
								end
								dirs[#dirs + 1] = entry
							end

							return dirs
						end,
					},
					{ section = "startup" },
				},
			},
			git = { enabled = true },
			gitbrowse = { enabled = true },
			scratch = { enabled = true },
		},
	},

	-- toggle golden ratio
	{
		"roman/golden-ratio",
		keys = {
			{ "<leader>tg", golden_ratio_toggle, desc = "Golden Ratio" },
		},
		init = function()
			vim.g.golden_ratio_enabled = 0
		end,
		config = function()
			vim.cmd.GoldenRatioToggle()
		end,
	},

	-- show search/replace results as they are being typed
	{ "haya14busa/incsearch.vim", event = "VeryLazy" },

	-- fidget.nvim shows lsp and null-ls status at the bottom right of the screen
	{ "j-hui/fidget.nvim", event = "LspAttach", tag = "legacy", config = true },

	-- automatically close inactive buffers
	{ "chrisgrieser/nvim-early-retirement", config = true, event = { "BufAdd" } },

	-- sessions
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		keys = {
			{ "<leader>wsr", "<cmd>lua require('persistence').load()<cr>", desc = "Session restore" },
			{ "<leader>ws/", "<cmd>lua require('persistence').select()<cr>", desc = "Session select" },
			{ "<leader>wsl", "<cmd>lua require('persistence').load({ last = true })<cr>", desc = "Load last session" },
			{ "<leader>wsd", "<cmd>lua require('persistence').stop()<cr>", desc = "Stop session manager" },
		},
		opts = {
			-- add any custom options here
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 700
		end,
		opts = {
			preset = "modern",
			plugins = { spelling = true },
			icons = { mappings = false },
		},
		config = function(_, opts)
			local wk = require("which-key")
			local keymap = require("ao.keymap")
			wk.setup(opts)
			wk.add(keymap.key_categories)
		end,
	},
}

return M
