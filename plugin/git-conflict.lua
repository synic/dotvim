vim.pack.add({ "https://github.com/akinsho/git-conflict.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("git-conflict").setup({})
	end,
})
