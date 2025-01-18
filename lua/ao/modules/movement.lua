---@alias HopOpts { keys: string, quit_key: string, case_insensitive: boolean }
---@alias TreewalkerOpts { highlight: boolean }

---@type string
local target_keys = "asdfghjkletovxpzwciubrnym;,ASDFGHJKLETOVXPZWCIUBRNYM"

---@return nil
local function pick_window()
	---@type number|nil
	local win_id = require("window-picker").pick_window({ hint = "floating-big-letter" })

	if win_id ~= nil then
		vim.api.nvim_set_current_win(win_id)
	end
end

---@type LazyPluginSpec[]
return {
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
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		version = "2.*",
		config = true,
		keys = {
			{ "<leader>w<leader>", pick_window, desc = "Jump to window" },
		},
	},
}
