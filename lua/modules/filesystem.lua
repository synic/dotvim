local f = require("core.functions")

vim.g.netrw_liststyle = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_browse_split = 0
vim.g.NERDTreeHijackNetrw = 0

vim.keymap.set("n", "-", f.netrw_current_file)
vim.keymap.set("n", "_", f.netrw_current_project)

return {
	{
		"kevinhwang91/rnvimr",
		config = function()
			vim.g.rnvimr_enable_picker = 1
			vim.g.rnvimr_enable_bw = 1
			vim.keymap.set("n", "<space>ff", ":RnvimrToggle<cr>")
		end,
	},

	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { { "nvim-telescope/telescope.nvim" } },
		config = function()
			local ok, telescope = pcall(require, "telescope")
			if not ok then
				return
			end

			telescope.load_extension("file_browser")
		end,
	},
}
