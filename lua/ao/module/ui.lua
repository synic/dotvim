-- @diagnostic disable: inject-field
local tbl = require("ao.tbl")
local proj = require("ao.module.proj")

local notification_width = 70
local clear_winbar_group = vim.api.nvim_create_augroup("WinBarHlClearBg", { clear = true })

---@type PluginModule
local M = {}

---@param full? boolean
---@return nil
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

---@return nil
function M.buffer_show_full_path()
	M.buffer_show_path(true)
end

-- excluding the current window, move all cursors to 0 position on their current line
-- for all windows in the current tab
---@param tabnr? integer
---@param exclude_current? boolean
---@return nil
function M.zero_window_cursors(tabnr, exclude_current)
	local current = vim.fn.winnr()

	for nr, _ in ipairs(vim.api.nvim_tabpage_list_wins(tabnr or 0)) do
		if current ~= nr or not exclude_current then
			vim.cmd(nr .. "windo norm 0")
		end
	end

	vim.cmd(current .. "windo normal! m'")
end

---@param tabnr? integer
---@return nil
function M.zero_all_window_cursors(tabnr)
	M.zero_window_cursors(tabnr, true)
end

-- Execute a command across all tabs
---@param cmd string
---@return nil
function M.tabdo(cmd)
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("tabdo " .. cmd)
	vim.cmd(current_tab .. "tabnext") -- restore original tab position
end

-- Equalize windows in all tabs
---@return nil
function M.equalize_all_tabs()
	M.tabdo("wincmd =")
end

---@return nil
function M.quickfix_remove_item_move_next()
	vim.cmd.copen()
	local curqfidx = vim.fn.line(".")
	local qfall = vim.fn.getqflist()

	if #qfall == 0 then
		return
	end

	table.remove(qfall, curqfidx)

	vim.fn.setqflist(qfall, "r")

	if #qfall == 0 then
		return
	end

	local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)
	vim.api.nvim_win_set_cursor(vim.fn.win_getid(), { new_idx, 0 })
	vim.cmd("cc" .. new_idx)
end

---@return nil
function M.layout_set_name()
	---@diagnostic disable-next-line: missing-fields
	vim.ui.input({ prompt = "layout name: ", default = (vim.t.layout_name or "") }, function(name)
		if name then
			---@diagnostic disable-next-line: inject-field
			vim.t.layout_name = name
			vim.cmd.redrawtabline()
		end
	end)
end

---@return nil
function M.goto_lazy_dir()
	local path = vim.fn.resolve(vim.fn.stdpath("data") .. "/" .. "lazy")
	vim.cmd.edit(path)
end

---@return nil
function M.goto_dotfiles_dir()
	vim.cmd.edit(vim.fn.expand("~/.dotfiles"))
end

---@param trunc_width? integer
---@param trunc_len? integer
---@param hide_width? integer
---@param no_ellipsis? boolean
---@return fun(str: string): string
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

---@return nil
local function golden_ratio_toggle()
	vim.cmd.GoldenRatioToggle()
	if vim.g.golden_ratio_enabled == 0 then
		---@diagnostic disable-next-line: inject-field
		vim.g.golden_ratio_enabled = 1
		vim.notify("Golden Ratio: enabled")
	else
		---@diagnostic disable-next-line: inject-field
		vim.g.golden_ratio_enabled = 0
		vim.notify("Golden Ratio: disabled")
		---@diagnostic disable-next-line: inject-field
		vim.g.equalalways = true
		M.equalize_all_tabs()
	end
end

---@param tabnr integer
---@return string|nil
function M.get_tab_name(tabnr)
	return proj.get_name(tabnr)
end

M.plugins = {
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			select = { enabled = false },
		},
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
		---@return dropbar_configs_t
		opts = function()
			local dutils = require("dropbar.utils")
			local preview = false
			local ignore = { "gitcommit" }
			local include = { "oil" }
			return {
				bar = {
					enable = function(buf, win)
						if tbl.contains(include, vim.bo[buf].filetype) then
							return true
						end

						return vim.fn.win_gettype(win) == ""
							and vim.wo[win].winbar == ""
							and vim.bo[buf].bt == ""
							and not tbl.contains(ignore, vim.bo[buf].ft)
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
						---@diagnostic disable-next-line: inject-field
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
		---@return table<string, any> # LualineConfig
		opts = function()
			local lualine_utils = require("lualine.utils.utils")

			local function repo_name(_, is_focused)
				if not is_focused then
					return ""
				end

				local path = proj.find_buffer_root()
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
			{
				"<leader>sn",
				"<cmd>lua require('snacks').notifier.show_history()<cr>",
				desc = "Show notification history",
			},
		},
		opts = function(_, opts)
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
				"[oil] could not find adapter for buffer '://'",
				"Could not find oil adapter for scheme '://'",
			}
			---@type snacks.Config
			return vim.tbl_deep_extend("force", {
				indent = {
					indent = { enabled = false },
					scope = { char = "╎", only_current = true },
					filter = function(buf)
						---@diagnostic disable-next-line: undefined-field
						return vim.g.snacks_indent ~= false
							and vim.b[buf].snacks_indent ~= false
							and not tbl.contains(disable_scope_filetypes, vim.bo[buf].filetype)
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
						if tbl.contains(notifier_ignore_messages, notif.msg) then
							return false
						end

						return true
					end,
				},
				git = { enabled = true },
				gitbrowse = { enabled = true },
				scratch = { enabled = true },
			}, opts)
		end,
	},

	-- toggle golden ratio
	{
		"roman/golden-ratio",
		keys = {
			{ "<leader>tg", golden_ratio_toggle, desc = "Golden Ratio" },
		},
		init = function()
			---@diagnostic disable-next-line: inject-field
			vim.g.golden_ratio_enabled = 0
		end,
		config = function()
			vim.cmd.GoldenRatioToggle()
		end,
	},

	-- show search/replace results as they are being typed
	{ "haya14busa/incsearch.vim", event = "VeryLazy" },

	-- automatically close inactive buffers
	{ "chrisgrieser/nvim-early-retirement", config = true, event = { "BufAdd" } },

	-- sessions
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		keys = {
			{ "<leader>wsr", "<cmd>lua require('persistence').load()<cr>", desc = "Session restore" },
			{ "<leader>ws/", "<cmd>lua require('persistence').select()<cr>", desc = "Session select" },
			{ "<leader>wsl", "<cmd>lua require('persistence').load({ last = true })<cr>", desc = "Load last session" },
			{ "<leader>wsd", "<cmd>lua require('persistence').stop()<cr>", desc = "Stop session manager" },
		},
		config = function(_, opts)
			-- stylua: ignore start
			vim.opt.sessionoptions = {
				"buffers",      -- hidden and unloaded buffers
				"folds",        -- manually created folds
				"help",         -- the help window
				"tabpages",     -- all tab pages
				"terminal",     -- terminal windows
				"winpos",       -- position of the whole Vim window
				"winsize",      -- window sizes
			}
			-- stylua: ignore end
			require("persistence").setup(opts)
		end,
	},

	-- key discoverability
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 700
		end,
		---@type wk["Opts"]
		---@diagnostic disable-next-line: missing-fields
		opts = {
			preset = "modern",
			plugins = { spelling = true },
			icons = { mappings = false },
		},
		config = function(_, opts)
			local wk = require("which-key")
			local keymap = require("ao.keymap")
			wk.setup(opts)
			wk.add(keymap.categories)
		end,
	},
}

return M
