vim.pack.add({ "https://github.com/roman/golden-ratio" })

vim.g.golden_ratio_enabled = 0
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd.GoldenRatioToggle()
	end,
})
