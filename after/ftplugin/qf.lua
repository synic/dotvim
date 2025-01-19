local key = require("ao.core.key")
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

key.map({
	{ "<localleader>q", "<cmd>cclose<cr>", desc = "Close quickfix", buffer = true },
	{ "<localleader>l", toggle_height, desc = "Toggle larger view", buffer = true },
	{ "<localleader>,", set_cursor_to_line, desc = "Set cursor to current line", buffer = true },
})
