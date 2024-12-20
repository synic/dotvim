local target_keys = "asdfghjkletovxpzwciubrnym;,ASDFGHJKLETOVXPZWCIUBRNYM"

local function pick_window()
	local win_id = require("window-picker").pick_window({ hint = "floating-big-letter" })

	if win_id ~= nil then
		vim.api.nvim_set_current_win(win_id)
	end
end

-- Smart hop on `f`, `F`, `t`, and `T`
--
-- If there's only one of the target char in the direction specified, just go there (default behavior). Otherwise, use
-- hop to label the duplicates with target labels
local function smart_hop(opts)
	local hop = require("hop")
	local default_opts = setmetatable({}, { __index = require("hop.defaults") })
	local jump_regex = require("hop.jump_regex")
	local function check_opts(o)
		if not o then
			return
		end

		if vim.version.cmp({ 0, 10, 0 }, vim.version()) < 0 then
			local hint = require("hop.hint")
			o.hint_type = hint.HintType.OVERLAY
		end
	end

	local function override_opts(o)
		check_opts(o)
		return setmetatable(o or {}, { __index = default_opts })
	end
	local char = vim.fn.getchar()

	char = type(char) == "number" and vim.fn.nr2char(char) or char

	-- Get current line and cursor position
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	-- Count occurrences based on direction
	local count
	if opts.direction == require("hop.hint").HintDirection.AFTER_CURSOR then
		local after_cursor = line:sub(col + 2)
		count = select(2, after_cursor:gsub(vim.pesc(char), ""))
	else
		local before_cursor = line:sub(1, col + 1)
		count = select(2, before_cursor:gsub(vim.pesc(char), ""))
	end

	if count <= 1 then
		-- Use native motion for 0 or 1 occurrence
		vim.cmd("normal! " .. opts.motion .. char)
	else
		opts = override_opts({
			direction = opts.direction,
			current_line_only = true,
			hint_offset = opts.hint_offset,
		})
		-- Use hop for multiple occurrences
		hop.hint_with_regex(jump_regex.regex_by_case_searching(char, true, opts), opts)
	end
end

return {
	{
		"smoka7/hop.nvim",
		version = "*",
		opts = { keys = target_keys, quit_key = "q" },
		config = function(_, opts)
			local hop = require("hop")
			hop.setup(opts)

			-- Create custom command for hopping to character/word matches
			vim.api.nvim_create_user_command("HopOverwinF", function()
				local char = vim.fn.getchar()
				-- Convert numeric char code to string
				char = type(char) == "number" and vim.fn.nr2char(char) or char

				-- Ignore whitespace characters
				if char:match("%s") then
					return
				end

				-- Create pattern based on input character type
				local pattern
				if char:match("%a") then
					-- For letters: match words starting with that letter
					-- Uppercase letters match exactly
					-- Lowercase letters match case insensitive only when the setting is enabled
					local case_flag = (opts.case_insensitive and char:match("%l")) and "\\c" or ""
					pattern = "\\v" .. case_flag .. "(<|_@<=)" .. char
				elseif char:match("%p") then
					-- For punctuation: match them literally
					pattern = [[\V]] .. vim.fn.escape(char, "\\")
				else
					-- For other characters: match them literally
					pattern = char
				end

				---@diagnostic disable-next-line: missing-fields
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
			{
				"f",
				function()
					smart_hop({
						direction = require("hop.hint").HintDirection.AFTER_CURSOR,
						motion = "f",
						hint_offset = 0,
					})
				end,
				desc = "Smart hop char after cursor",
				mode = { "n", "v" },
			},
			{
				"F",
				function()
					smart_hop({
						direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
						motion = "F",
						hint_offset = 0,
					})
				end,
				desc = "Smart hop char before cursor",
				mode = { "n", "v" },
			},
			{
				"t",
				function()
					smart_hop({
						direction = require("hop.hint").HintDirection.AFTER_CURSOR,
						motion = "t",
						hint_offset = -1,
					})
				end,
				desc = "Smart hop before char after cursor",
				mode = { "n", "v" },
			},
			{
				"T",
				function()
					smart_hop({
						direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
						motion = "T",
						hint_offset = 1,
					})
				end,
				desc = "Smart hop before char before cursor",
				mode = { "n", "v" },
			},
		},
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = { enabled = false },
			},
			labels = target_keys,
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

	{
		"aaronik/treewalker.nvim",
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
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		version = "2.*",
		config = true,
		keys = {
			{ "<leader>w<leader>", pick_window, desc = "Jump to window" },
		},
	},
}
