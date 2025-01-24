return {
	treesitter = { "elixir", "heex" },
	servers = {
		["nextls"] = function()
			require("lspconfig").nextls.setup({
				init_options = {
					experimental = {
						completions = { enable = true },
					},
				},
			})
		end,
	},
	plugins = {
		{
			"synic/refactorex.nvim",
			ft = "elixir",
			config = true,
		},
	},
}
