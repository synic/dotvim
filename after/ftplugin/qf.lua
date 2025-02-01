local keymap = require("ao.keymap")
local default_height = vim.fn.winheight(0)

local function toggle_height()
	local current_height = vim.fn.winheight(0)
	local set_height = 60

	if current_height == default_height then
		set_height = 60
	elseif current_height == 60 then
		set_height = 90
	else
		set_height = default_height
	end

	vim.api.nvim_win_set_height(0, set_height)
end

local function set_cursor_to_line()
	vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), 0 })
end

local function view_next_item()
	local current_win = vim.fn.win_getid()
	vim.cmd.cn()
	pcall(vim.api.nvim_set_current_win, current_win)
end

local function view_prev_item()
	local current_win = vim.fn.win_getid()
	vim.cmd.cp()
	pcall(vim.api.nvim_set_current_win, current_win)
end

keymap.add({
	{ "<c-j>", view_next_item, desc = "Go to next item", buffer = true },
	{ "<c-k>", view_prev_item, desc = "Go to previous item", buffer = true },
	{ "<localleader>q", "<cmd>cclose<cr>", desc = "Close quickfix", buffer = true },
	{ "<localleader>l", toggle_height, desc = "Toggle larger view", buffer = true },
	{
		"<localleader>L",
		function()
			vim.api.nvim_win_set_height(0, 90)
		end,
		desc = "Toggle larger view",
		buffer = true,
	},
	{ "<localleader>,", set_cursor_to_line, desc = "Set cursor to current line", buffer = true },
})
