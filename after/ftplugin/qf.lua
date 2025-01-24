-- local quicker, quicker_installed = require("quicker")
local keymap = require("ao.keymap")
local default_height = vim.fn.winheight(0)
local expand_step = 2

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

-- local function expand_quickfix()
-- 	quicker.expand({ before = expand_step, after = expand_step, add_to_existing = true })
-- end
--
-- local function collapse_quickfix()
-- 	quicker.collapse()
-- end
--
-- if quicker_installed then
-- 	quicker.collapse()
-- end

keymap.add({
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
	-- { ">", expand_quickfix, desc = "Expand quickfix", buffer = true },
	-- { "<", collapse_quickfix, desc = "Expand quickfix", buffer = true },
})
