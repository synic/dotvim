local f = require("core.functions")

vim.g.netrw_liststyle = 1
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.NERDTreeHijackNetrw = 0

vim.keymap.set("n", "-", f.netrw_current_file)
vim.keymap.set("n", "_", f.netrw_current_project)

return function(use)
	use("ibhagwan/fzf-lua")
	use("dbakker/vim-projectroot")
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
		config = function()
			local telescope = require("telescope")

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
			vim.keymap.set("n", "<space>pr", ":Telescope oldfiles<cr>")
			vim.keymap.set("n", "<space>sp", ":Telescope live_grep<cr>")
			vim.keymap.set("n", "<space>rl", ":Telescope resume<cr>")
		end,
	})
	use({
		"airblade/vim-rooter",
		config = function()
			vim.g.rooter_silent_chdir = 1
		end,
	})
	use({
		"nvim-telescope/telescope-project.nvim",
		config = function()
			local ok, telescope = pcall(require, "telescope")
			if not ok then
				return
			end

			telescope.load_extension("project")
		end,
	})
	use({
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({})

			local ok, telescope = pcall(require, "telescope")
			if not ok then
				return
			end

			telescope.load_extension("projects")

			local function load_projects()
				require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
			end

			vim.keymap.set("n", "<space>bh", load_projects)
			vim.keymap.set("n", "<space>pp", ":Telescope find_files cwd=~/Projects find_command=fd,-d,1,.<cr>")
		end,
	})
end
