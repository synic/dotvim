vim.cmd([[
	function! s:ZoomToggle() abort
		if exists('t:zoomed') && t:zoomed
			execute t:zoom_winrestcmd
			let t:zoomed = 0
		else
			let t:zoom_winrestcmd = winrestcmd()
			resize
			vertical resize
			let t:zoomed = 1
		endif
	endfunction
	command! ZoomToggle call s:ZoomToggle()
]])

vim.keymap.set("n", "<space>Pu", ":Lazy update<cr>")
vim.keymap.set("n", "<space>Ps", ":Lazy sync<cr>")
vim.keymap.set("n", "<space>wM", ":ZoomToggle<cr>")

return {
	"ConradIrwin/vim-bracketed-paste",
	{
		"s1n7ax/nvim-terminal",
		config = function()
			require("nvim-terminal").setup({
				disable_default_keymaps = true,
			})

			vim.keymap.set("n", "<space>'", ':lua NTGlobal["terminal"]:toggle()<cr>', { silent = true })
		end,
	},
	"wakatime/vim-wakatime",
}
