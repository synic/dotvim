local f = require("ao.core")

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
		keys = { "<space>ff", "<cmd>RnvimrToggle<cr>", desc = "Ranger" },
		config = function()
			vim.g.rnvimr_enable_picker = 1
			vim.g.rnvimr_enable_bw = 1
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		keys = {
			{ "<space>pt", "<cmd>lua require('ao.functions').neotree_project_root()<cr>", desc = "Neotree" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				filesystem = {
					hijack_netrw_behavior = "disabled",
				},
			})
		end,
	},
}
