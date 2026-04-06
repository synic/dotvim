vim.pack.add({ "https://github.com/wansmer/treesj" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("treesj").setup({
			max_join_length = 2000,
			use_default_keymaps = false,
		})
	end,
})
