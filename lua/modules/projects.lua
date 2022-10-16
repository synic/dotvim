local f = require("core.functions")

vim.g.netrw_liststyle = 1
vim.g.netrw_keepdir = 0
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
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					project = {
						base_dirs = {
							{ "~/Projects", max_depth = 1 },
						},
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

			local function load_projects()
				require("telescope").extensions.project.project({
					display_type = "full",
					layout_config = { width = 0.5, height = 0.5 },
				})
			end

			vim.keymap.set("n", "<space>pp", load_projects)
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
		end,
	})
end
