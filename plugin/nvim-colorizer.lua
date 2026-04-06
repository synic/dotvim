vim.pack.add({ { src = "https://github.com/norcalli/nvim-colorizer.lua", name = "colorizer" } })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("colorizer").setup({
			"javascript",
			"css",
			"html",
			"templ",
			"sass",
			"scss",
			"typescript",
			"json",
			"lua",
		})
	end,
})
