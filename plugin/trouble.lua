vim.pack.add({ "https://github.com/folke/trouble.nvim" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		require("trouble").setup({})
	end,
})
