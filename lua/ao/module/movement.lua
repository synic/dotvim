local keymap = require("ao.keymap")

local M = {}
---@alias HopOpts { keys: string, quit_key: string, case_insensitive: boolean }
---@alias TreewalkerOpts { highlight: boolean }

---@type string
local target_keys = "asdfghjkletovxpzwciubrnym;,ASDFGHJKLETOVXPZWCIUBRNYM"
local last_edit_pos = nil
local toggle_pos = nil

local function get_current_pos()
	return {
		buf = vim.api.nvim_get_current_buf(),
		row = vim.api.nvim_win_get_cursor(0)[1],
		col = vim.api.nvim_win_get_cursor(0)[2],
	}
end

local function go_to_pos(pos)
	if not vim.api.nvim_buf_is_valid(pos.buf) then
		print("Buffer no longer exists")
		return false
	end
	
	if pos.buf ~= vim.api.nvim_get_current_buf() then
		vim.api.nvim_set_current_buf(pos.buf)
	end
	
	local line_count = vim.api.nvim_buf_line_count(pos.buf)
	if pos.row > line_count then
		print("Line no longer exists")
		return false
	end
	
	vim.api.nvim_win_set_cursor(0, { pos.row, pos.col })
	return true
end

function M.toggle_last_edit()
	if not last_edit_pos then
		print("No previous edit location")
		return
	end

	local current_pos = get_current_pos()

	if
		last_edit_pos.buf == current_pos.buf
		and last_edit_pos.row == current_pos.row
		and last_edit_pos.col == current_pos.col
		and toggle_pos
	then
		if not go_to_pos(toggle_pos) then
			toggle_pos = nil
		end
	else
		toggle_pos = current_pos
		if not go_to_pos(last_edit_pos) then
			last_edit_pos = nil
		end
	end
end

local function track_edit()
	local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
	
	if buftype == "" and filetype ~= "oil" then
		last_edit_pos = get_current_pos()
	end
end

vim.api.nvim_create_augroup("TrackEdits", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	group = "TrackEdits",
	callback = track_edit,
})

keymap.add({
	{
		"<leader>'",
		M.toggle_last_edit,
		desc = "Toggle last edit location",
	},
})
---@type PluginModule
M.plugins = {
	{
		"smoka7/hop.nvim",
		version = "*",
		---@type HopOpts
		opts = { keys = target_keys, quit_key = "q" },
		---@param _ any
		---@param opts HopOpts
		config = function(_, opts)
			---@type table
			local hop = require("hop")
			hop.setup(opts)

			vim.api.nvim_create_user_command("HopOverwinF", function()
				---@type number|string
				local char = vim.fn.getchar()
				char = type(char) == "number" and vim.fn.nr2char(char) or char

				if char:match("%s") then
					return
				end

				---@type string
				local pattern
				if char:match("%a") then
					---@type string
					local case_flag = (opts.case_insensitive and char:match("%l")) and "\\c" or ""
					pattern = "\\v" .. case_flag .. "(<|_@<=)" .. char
				elseif char:match("%p") then
					pattern = [[\V]] .. vim.fn.escape(char, "\\")
				else
					pattern = char
				end

				hop.hint_patterns({
					current_line_only = false,
					multi_windows = true,
					hint_position = require("hop.hint").HintPosition.BEGIN,
				}, pattern)
			end, { desc = "Hop to words starting with input character" })
		end,
		keys = {
			{ "<leader><leader>", "<cmd>HopOverwinF<cr>", desc = "Hop to word", mode = { "v", "n" } },
			{ ";b", "<cmd>HopWordBC<cr>", desc = "Hop to word before cursor", mode = { "v", "n" } },
			{ ";w", "<cmd>HopWord<cr>", desc = "Hop to word in current buffer", mode = { "v", "n" } },
			{ ";a", "<cmd>HopWordAC<cr>", desc = "Hop to word after cursor", mode = { "v", "n" } },
			{ ";c", "<cmd>HopCamelCaseMW<cr>", desc = "Hop to camelCase word", mode = { "v", "n" } },
			{ ";d", "<cmd>HopLine<cr>", desc = "Hop to line", mode = { "v", "n" } },
			{ ";f", "<cmd>HopNodes<cr>", desc = "Hop to node", mode = { "v", "n" } },
			{ ";s", "<cmd>HopPatternMW<cr>", desc = "Hop to pattern", mode = { "v", "n" } },
			{ ";j", "<cmd>HopVertical<cr>", desc = "Hop to location vertically", mode = { "v", "n" } },
		},
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			modes = {
				char = { enabled = false },
			},
			labels = target_keys,
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"<leader>S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	{
		"aaronik/treewalker.nvim",
		---@type TreewalkerOpts
		opts = {
			highlight = true,
		},
		keys = {
			{ "<C-j>", "<cmd>Treewalker Down<cr>", mode = { "n", "v" } },
			{ "<C-k>", "<cmd>Treewalker Up<cr>", mode = { "n", "v" } },
			{ "<C-h>", "<cmd>Treewalker Left<cr>", mode = { "n", "v" } },
			{ "<C-l>", "<cmd>Treewalker Right<cr>", mode = { "n", "v" } },
		},
	},

	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
		},
		keys = {
			{ "<leader>wh", "<cmd>TmuxNavigateLeft<cr>", desc = "Go left" },
			{ "<leader>wj", "<cmd>TmuxNavigateDown<cr>", desc = "Go down" },
			{ "<leader>wk", "<cmd>TmuxNavigateUp<cr>", desc = "Go up" },
			{ "<leader>wl", "<cmd>TmuxNavigateRight<cr>", desc = "Go right" },
		},
	},
}

return M
