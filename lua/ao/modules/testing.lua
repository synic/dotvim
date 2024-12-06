local function open_summary()
	return function()
		require("neotest").summary.open()
		if vim.bo.filetype == "elixir" then
			vim.cmd.w()
		end
	end
end

return {
	{
		"nvim-neotest/neotest",
		event = "BufEnter",
		keys = {
			{ "<localleader>tn", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
			{ "<localleader>t,", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
			{ "<localleader>tb", "<cmd>lua require('neotest').run.run(vim.fn.expand('%s'))<cr>", desc = "Run buffer" },
			{ "<localleader>ts", open_summary(), desc = "Show summary" },
		},
		dependencies = {
			"jfpedroza/neotest-elixir",
			"nvim-neotest/neotest-go",
			"nvim-neotest/neotest-python",
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			---@diagnostic disable: missing-fields
			require("neotest").setup({
				adapters = {
					require("neotest-elixir"),
					require("neotest-python"),
					require("neotest-go"),
				},
			})
		end,
	},
}
