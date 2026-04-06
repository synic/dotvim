vim.pack.add({ "https://github.com/L3MON4D3/LuaSnip" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("luasnip.loaders.from_snipmate").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})
		require("luasnip.loaders.from_vscode").lazy_load()
	end,
})
