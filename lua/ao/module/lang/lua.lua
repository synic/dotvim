return {
	treesitter = { "lua" },
	nonels = { "formatting.stylua" },
	plugins = {
		-- neovim development
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					{ path = "snacks.nvim", words = { "Snacks" } },
					{ path = "lazy.nvim", words = { "LazyVim" } },
					{ path = "which-key.nvim", words = { "WhichKey" } },
					{ path = "blink.cmp", words = { "Blink" } },
				},
			},
		},
	},
}
