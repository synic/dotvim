local function neotree_project_root()
	local project_dir = vim.fn.ProjectRootGuess()
	vim.cmd(":Neotree " .. project_dir)
end

local function netrw_current_file()
	local pathname = vim.fn.expand("%:p:h")
	vim.fn.execute("edit " .. pathname)
end

local function netrw_current_project()
	local pathname = vim.fn.ProjectRootGuess()
	vim.fn.execute("edit " .. pathname)
end

vim.g.netrw_liststyle = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_browse_split = 0
vim.g.NERDTreeHijackNetrw = 0

vim.keymap.set("n", "-", netrw_current_file, { desc = "browse current directory" })
vim.keymap.set("n", "_", netrw_current_project, { desc = "browse project directory" })

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		keys = {
			{ "<leader>pt", neotree_project_root, desc = "neotree" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"dbakker/vim-projectroot",
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
