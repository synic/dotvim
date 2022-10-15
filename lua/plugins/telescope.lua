local status, telescope = pcall(require, "telescope")

if not status then
	return
end

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
})

telescope.load_extension("fzf")

vim.keymap.set("n", "<space>bb", ":Telescope buffers<cr>")
vim.keymap.set("n", "<space>ph", ":Telescope git_files<cr>")
vim.keymap.set("n", "<space>bh", ":Telescope projects<cr>")
vim.keymap.set("n", "<space>pr", ":Telescope oldfiles<cr>")
vim.keymap.set("n", "<space>sp", ":Telescope live_grep<cr>")
