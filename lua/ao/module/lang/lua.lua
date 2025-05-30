return {
	treesitter = { "lua" },
	nonels = { "formatting.stylua" },
	only_nonels_formatting = true,
	servers = {
		["lua_ls"] = function()
			require("lspconfig").lua_ls.setup({
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
			})
		end,
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
