vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

local filetypes = { "markdown" }

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function()
		require("render-markdown").setup({
			file_types = filetypes,
		})
	end,
})
