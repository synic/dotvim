return {
	nonels = { "formatting.stylua" },
	format_on_save = "nonels",
	servers = {
		["lua_ls"] = {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						path = { "?.lua", "?/init.lua", "lua/?.lua", "lua/?/init.lua" },
					},
					diagnostics = { globals = { "vim", "hs" } },
					completion = { callSnippet = "Replace", autoRequire = true, displayContext = 7 },
				},
			},
		},
	},
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
