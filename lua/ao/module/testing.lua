local function open_summary()
	return function()
		require("neotest").summary.toggle()
		if vim.bo.filetype == "elixir" then
			-- Check if neotest-summary window exists
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "neotest-summary" then
					vim.cmd.w()
					break
				end
			end
		end
	end
end

---@type PluginModule
return {
	{
		"nvim-neotest/neotest",
		ft = { "go", "python", "elixir" },
		keys = {
			{ "<leader>dtn", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
			{ "<leader>dt,", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run nearest test" },
			{ "<leader>dtb", "<cmd>lua require('neotest').run.run(vim.fn.expand('%s'))<cr>", desc = "Run buffer" },
			{ "<leader>dts", open_summary(), desc = "Toggle summary" },
		},
		dependencies = {
			"jfpedroza/neotest-elixir",
			"nvim-neotest/neotest-go",
			"nvim-neotest/neotest-python",
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
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
