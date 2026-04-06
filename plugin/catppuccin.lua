vim.pack.add({
	{
		src = "https://github.com/catppuccin/nvim",
		name = "catppuccin",
	},
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("catppuccin").setup({
			flavor = "macchiato",
		})

		require("modules.themes").on_colorscheme_load("^catppuccin", function()
			vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#b4befe", bg = "#45475a" })
		end)
	end,
})
