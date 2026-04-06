vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("3") } })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("nvim-surround").setup({
			surrounds = {
				["%"] = {
					add = function()
						if vim.bo.filetype == "elixir" then
							return {
								"%{",
								"}",
							}
						end
					end,
				},
			},
		})
	end,
})
