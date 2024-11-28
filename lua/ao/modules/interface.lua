local utils = require("ao.utils")
local filesystem = require("ao.modules.filesystem")
local projects = require("ao.modules.projects")
local clear_winbar_group = vim.api.nvim_create_augroup("WinBarHlClearBg", { clear = true })
local indentscope_disable_group = vim.api.nvim_create_augroup("MiniIndentScopeDisable", { clear = true })

local M = {}

local key_categories = {
	{ "<leader>-", group = "split" },
	{ "<leader>/", group = "vsplit" },
	{ "<leader>b", group = "buffers" },
	{ "<leader>c", group = "configuration" },
	{ "<leader>cp", group = "plugins" },
	{ "<leader>d", group = "debug" },
	{ "<leader>e", group = "diagnostis" },
	{ "<leader>f", group = "files" },
	{ "<leader>g", group = "git" },
	{ "<leader>h", group = "help" },
	{ "<leader>l", group = "layouts" },
	{ "<leader>p", group = "project" },
	{ "<leader>q", group = "quickfix" },
	{ "<leader>s", group = "search" },
	{ "<leader>t", group = "toggles" },
	{ "<leader>w", group = "windows" },
	{ "<leader>wm", group = "move" },
	{ "<leader>x", group = "misc" },
	{ "gh", group = "hunk" },
}

local function buffer_show_path(full)
	local pattern = "%p"

	if full then
		pattern = "%:p"
	end

	local path = vim.fn.expand(pattern)
	vim.fn.setreg("+", path)
	vim.notify(path)
	print(path)
end

local function buffer_show_full_path()
	buffer_show_path(true)
end

-- excluding the current window, move all cursors to 0 position on their current line
-- for all windows in the current tab
local function zero_window_cursors(tabnr, exclude_current)
	local current = vim.fn.winnr()

	for nr, _ in ipairs(vim.api.nvim_tabpage_list_wins(tabnr or 0)) do
		if current ~= nr or not exclude_current then
			vim.cmd(nr .. "windo norm 0")
		end
	end

	vim.cmd(current .. "windo normal! m'")
end

local function zero_all_window_cursors(tabnr)
	zero_window_cursors(tabnr, true)
end

local function quickfix_remove_item_move_next()
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

local function layout_set_name()
	vim.ui.input({ prompt = "layout name: ", default = (vim.t.layout_name or "") }, function(name)
		if name then
			vim.t.layout_name = name
			vim.cmd.redrawtabline()
		end
	end)
end

local function goto_lazy_dir()
	local path = vim.fn.resolve(vim.fn.stdpath("data") .. "/" .. "lazy")
	vim.cmd.edit(path)
end

utils.map_keys({
	-- windows
	{ "<leader>wk", "<cmd>wincmd k<cr>", desc = "Go up" },
	{ "<leader>wj", "<cmd>wincmd j<cr>", desc = "Go down" },
	{ "<leader>wh", "<cmd>wincmd h<cr>", desc = "Go left" },
	{ "<leader>wl", "<cmd>wincmd l<cr>", desc = "Go right" },
	{ "<leader>w/", "<cmd>vs<cr>", desc = "Split vertically" },
	{ "<leader>w-", "<cmd>sp<cr>", desc = "Split horizontally" },
	{ "<leader>/w", "<cmd>vs<cr>", desc = "Split window vertically" },
	{ "<leader>-w", "<cmd>sp<cr>", desc = "Split window horizontally" },
	{ "<leader>wc", "<cmd>close<cr>", desc = "Close window" },
	{ "<leader>wd", "<cmd>q<cr>", desc = "Quit window" },
	{ "<leader>w=", "<C-w>=", desc = "Equalize windows" },
	{ "<leader>wH", "<cmd>wincmd h<cr><cmd>close<cr>", desc = "Close window to the left" },
	{ "<leader>wJ", "<cmd>wincmd j<cr><cmd>close<cr>", desc = "Close window below" },
	{ "<leader>wK", "<cmd>wincmd k<cr><cmd>close<cr>", desc = "Close window above" },
	{ "<leader>wL", "<cmd>wincmd l<cr><cmd>close<cr>", desc = "Close window to the right" },
	{ "<leader>wmh", "<cmd>wincmd H<cr>", desc = "Move window left" },
	{ "<leader>wmj", "<cmd>wincmd J<cr>", desc = "Move window down" },
	{ "<leader>wmk", "<cmd>wincmd K<cr>", desc = "Move window up" },
	{ "<leader>wml", "<cmd>wincmd L<cr>", desc = "Move window right" },
	{ "<leader>wR", "<cmd>wincmd R<cr>", desc = "Rotate windows" },
	{ "<leader>wT", "<cmd>wincmd T<cr>", desc = "Move to new layout" },
	{ "<leader>w;", zero_window_cursors, desc = "Move cursor to 0 in all but the current window" },
	{ "<leader>w;", zero_all_window_cursors, desc = "Move cursor to 0 in all windows" },
	{ "<leader>w1", "<cmd>1windo norm! m'<cr>", desc = "Goto window #1" },
	{ "<leader>w2", "<cmd>2windo norm! m'<cr>", desc = "Goto window #2" },
	{ "<leader>w3", "<cmd>3windo norm! m'<cr>", desc = "Goto window #3" },
	{ "<leader>w4", "<cmd>4windo norm! m'<cr>", desc = "Goto window #4" },
	{ "<leader>w5", "<cmd>5windo norm! m'<cr>", desc = "Goto window #5" },
	{ "<leader>w6", "<cmd>6windo norm! m'<cr>", desc = "Goto window #6" },
	{ "<leader>w7", "<cmd>7windo norm! m'<cr>", desc = "Goto window #7" },
	{ "<leader>w8", "<cmd>8windo norm! m'<cr>", desc = "Goto window #8" },
	{ "<leader>w9", "<cmd>9windo norm! m'<cr>", desc = "Goto window #9" },

	-- layouts/tabs
	{ "<leader>l.", "<cmd>tabnew<cr>", desc = "New layout" },
	{ "<leader>l1", "1gt", desc = "Go to layout #1" },
	{ "<leader>l2", "2gt", desc = "Go to layout #2" },
	{ "<leader>l3", "3gt", desc = "Go to layout #3" },
	{ "<leader>l4", "4gt", desc = "Go to layout #4" },
	{ "<leader>l5", "5gt", desc = "Go to layout #5" },
	{ "<leader>l6", "6gt", desc = "Go to layout #6" },
	{ "<leader>l7", "7gt", desc = "Go to layout #7" },
	{ "<leader>l8", "8gt", desc = "Go to layout #8" },
	{ "<leader>l9", "9gt", desc = "Go to layout #9" },
	{ "<leader>lc", "<cmd>tabclose<cr>", desc = "Close layout" },
	{ "<leader>ln", "<cmd>tabnext<cr>", desc = "Next layout" },
	{ "<leader>lp", "<cmd>tabprev<cr>", desc = "Previous layout" },
	{ "<leader>l<tab>", "g<Tab>", desc = "Go to last layout" },
	{ "<leader>lN", layout_set_name, desc = "Set layout name" },

	-- toggles
	{ "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "Toggle search highlights" },
	{ "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "Toggle relative line numbers" },
	{ "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "Toggle line number display" },
	{ "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "Toggle tab display" },
	{ "<leader>tc", "<cmd>let &cuc = !&cuc<cr>", desc = "Toggle cursor column display" },
	{ "<leader>ti", "<cmd>lua vim.opt.list = not vim.opt.list:get()<cr>", desc = "Toggle indent guide" },

	-- buffers
	{ "<leader><tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
	{ "<leader>b<tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
	{ "<leader>bd", "<cmd>bdelete!<cr>", desc = "Close current window and quit buffer" },
	{ "<leader>bp", buffer_show_path, desc = "Show buffer path" },
	{ "<leader>bP", buffer_show_full_path, desc = "Show full buffer path" },
	{ "<leader>bn", "<cmd>enew<cr>", desc = "New buffer" },

	-- help
	{ "<leader>hh", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },
	{ "<leader>?", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },

	-- quickfix
	{ "<leader>qq", "<cmd>copen<cr>", desc = "Open quickfix" }, -- overridden in trouble.nvim
	{ "<leader>qj", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>qk", "<cmd>cp<cr>", desc = "Previous quickfix item" },
	{ "<leader>qn", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>qp", "<cmd>cp<cr>", desc = "Previous quickfix item" }, -- overridden in trouble.nvim
	{ "<leader>qc", "<cmd>cclose<cr>", desc = "Close quickfix" },
	{ "g;", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>q<space>", quickfix_remove_item_move_next, desc = "Remove quickfix item and move next" },

	-- configuration
	{ "<leader>cm", filesystem.goto_config_directory, desc = "Manage config" },
	{ "<leader>cl", goto_lazy_dir, desc = "Go to lazy plugins dir" },

	-- copy/paste on mac
	{ "<D-v>", "+p<CR>", modes = { "" }, noremap = true, silent = true, test = vim.fn.has("macunix") },
	{ "<D-v>", "<C-R>+", modes = { "!", "t", "v" }, noremap = true, silent = true, test = vim.fn.has("macunix") },

	-- misc
	{ "vig", "ggVG", desc = "Select whole buffer" },
	{ "<leader><localleader>", "<localleader>", desc = "Local buffer options" },
	{ "<leader>xq", "<cmd>qa!<cr>", desc = "Quit Vim" },
	{ "<leader>xx", utils.close_all_floating_windows, desc = "Close all floating windows" },
	{ "<leader>'", "<cmd>split<cr><cmd>term<cr><cmd>norm A<cr>", desc = "Open terminal" },
})

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
		vim.cmd("wincmd =")
	end
end

function M.get_tab_name(tabnr)
	return projects.get_name(tabnr)
end

M.plugin_specs = {
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
			wk.setup(opts)
			wk.add(key_categories)
		end,
	},

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

	-- various interface and vim scripting utilities
	{
		"tpope/vim-scriptease",
		keys = {
			{ "<leader>sm", "<cmd>Messages<cr>", desc = "Show notifications/messages" },
		},
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
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			}
			vim.api.nvim_create_autocmd("FileType", {
				pattern = disable_for,
				group = indentscope_disable_group,
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})

			-- for lazy loading into an existing file
			if utils.table_contains(disable_for, vim.bo.filetype) then
				vim.b.miniindentscope_disable = true
			end
		end,
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
							local clicked_menu = dutils.menu.get({ win = mouse.winid })
							-- If clicked on a menu, invoke the corresponding click action,
							-- else close all menus and set the cursor to the clicked window
							if clicked_menu then
								clicked_menu:click_at({
									mouse.line,
									mouse.column - 1,
								}, nil, 1, "l")
								return
							end
							dutils.menu.exec("close")
							dutils.bar.exec("update_current_context_hl")
							if vim.api.nvim_win_is_valid(mouse.winid) then
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
						hl.ctermbg = nil
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
	-- get around faster and easier
	{
		"Lokaltog/vim-easymotion",
		init = function()
			vim.g.EasyMotion_smartcase = true
			vim.g.EasyMotion_do_mapping = false
		end,
		keys = {
			{ "<leader><leader>", "<plug>(easymotion-overwin-f)", desc = "Jump to location", mode = "n" },
			{ "<leader><leader>", "<plug>(easymotion-bd-f)", desc = "Jump to location", mode = "v" },
		},
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

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = { enabled = false },
			},
			labels = "asdfghjklwertyuiopzxcvbnmABCDEFGHIJKLMNOP",
		},
		-- stylua: ignore
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
	},

	-- show search/replace results as they are being typed
	{ "haya14busa/incsearch.vim", event = "VeryLazy" },

	-- fidget.nvim shows lsp and null-ls status at the bottom right of the screen
	{ "j-hui/fidget.nvim", event = "LspAttach", tag = "legacy", config = true },

	-- automatically close inactive buffers
	{ "chrisgrieser/nvim-early-retirement", config = true, event = { "BufAdd" } },
}

return M
