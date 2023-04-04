return function(use)
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
			local builtin = require("telescope.builtin")

			local function search_for_term(prompt_bufnr)
				local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
				local prompt = current_picker:_get_prompt()
				vim.cmd(":CtrlSF " .. prompt)
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
					file_browser = {
						theme = "ivy",
						hijack_netrw = false,
					},
				},
				pickers = {
					buffers = {
						sort_mru = true,
						ignore_current_buffer = true,
					},
					live_grep = {
						mappings = {
							i = {
								["<C-e>"] = search_for_term,
							},
						}
					},
					grep_string = {
						mappings = {
							i = {
								["<C-e>"] = search_for_term,
							},
						}
					},
				},
			})

			telescope.load_extension("fzf")

			local function search_cwd()
				builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
			end

			vim.keymap.set(
				"n",
				"<space>bb",
				":lua require('telescope.builtin').buffers"
					.. "({ sort_mru=true, sort_lastused=true, ignore_current_buffer=true })<cr>"
			)
			vim.keymap.set("n", "<space>ph", ":Telescope git_files<cr>")
			vim.keymap.set("n", "<space>fr", ":Telescope oldfiles<cr>")
			vim.keymap.set("n", "<space>sp", ":Telescope live_grep<cr>")
			vim.keymap.set("n", "<space>rl", ":Telescope resume<cr>")
			vim.keymap.set("n", "<space>sd", search_cwd)
			vim.keymap.set("n", "<space>gB", ":Telescope git_branches<cr>")
			vim.keymap.set("n", "<space>gS", ":Telescope git_stash<cr>")
			vim.keymap.set("n", "<space>ml", ":Telescope marks<cr>")
			vim.keymap.set("n", "<space>rr", ":Telescope registers<cr>")
			vim.keymap.set("n", "<space>ss", ":Telescope spell_suggest<cr>")
			vim.keymap.set("n", "<space>*", function()
				local current_word = vim.fn.expand("<cword>")
				local project_dir = vim.fn.ProjectRootGuess()
				builtin.grep_string({
					cwd = project_dir,
					search = current_word,
				})
			end)
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
			require("project_nvim").setup({
				manual_mode = false,
				detection_methods = { "pattern", "lsp" },
				patterns = {
					".git",
					"_darcs",
					".hg",
					".bzr",
					".svn",
					"Makefile",
					"package.json",
					"setup.cfg",
					"setup.py",
					"pyproject.toml",
				},
				ignore_lsp = {},
				exclude_dirs = {},
				show_hidden = false,
				silent_chdir = true,
				scope_chdir = "global",
				datapath = vim.fn.stdpath("data"),
			})

			local ok, telescope = pcall(require, "telescope")
			if not ok then
				return
			end

			telescope.load_extension("projects")

			local function load_projects()
				require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
			end

			local function new_tab_with_projects()
				vim.cmd(":tabnew<cr>")
				load_projects()
			end

			vim.keymap.set("n", "<space>pr", load_projects)
			vim.keymap.set("n", "<space>ll", new_tab_with_projects)
		end,
	})
end
