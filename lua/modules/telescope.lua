local function telescope_search_star()
	local builtin = require("telescope.builtin")
	local current_word = vim.fn.expand("<cword>")
	local project_dir = vim.fn.ProjectRootGuess()
	builtin.grep_string({
		cwd = project_dir,
		search = current_word,
	})
end

local function telescope_search_cwd()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

local function ctrlsf_search_for_term(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	local prompt = current_picker:_get_prompt()
	vim.cmd(":CtrlSF " .. prompt)
end

local function telescope_load_projects()
	require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
end

local function telescope_new_tab_with_projects()
	vim.cmd(":tabnew<cr>")
	telescope_load_projects()
end

local function telescope_project_files()
	local utils = require("telescope.utils")
	local builtin = require("telescope.builtin")

	local _, ret, _ = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
	if ret == 0 then
		builtin.git_files()
	else
		telescope_load_projects()
	end
end

return {
	{
		{
			"nvim-telescope/telescope.nvim",
			keys = {
				{
					"<space>bb",
					"<cmd>lua require('telescope.builtin').buffers({ sort_mru=true, sort_lastused=true, icnore_current_buffer=true })<cr>",
					desc = "show buffers",
				},
				{ "<space>pf", telescope_project_files, desc = "project files" },
				{ "<space>sp", "<cmd>Telescope live_grep<cr>", desc = "search in project files" },
				{ "<space>sd", telescope_search_cwd, desc = "search in current directory" },
				{ "<space>gB", "<cmd>Telescope git_branches<cr>", desc = "show git branches" },
				{ "<space>gS", "<cmd>Telescope git_stash<cr>", desc = "show git stashes" },
				{ "<leader>s", "<cmd>Telescope spell_suggest<cr>", desc = "spelling suggestions" },
				{ "<space>*", telescope_search_star, desc = "search for term globally" },
				{ "<space>pp", telescope_load_projects, desc = "projects" },
				{ "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "code actions" },
				-- files
				{ "<space>ff", "<cmd>Telescope find_files<cr>", desc = "fuzzy find files below cwd" },

				-- tab items
				{ "<space>tl", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "list layouts" },
				{ "<space>tN", "<cmd>tabnew<cr>", desc = "new layout" },
				{ "<space>tn", telescope_new_tab_with_projects, desc = "new layout with project" },

				-- lists
				{ "<space>ls", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "snippets" },
				{ "<space>lt", "<cmd>Telescope colorscheme<cr>", desc = "themes" },
				{ "<space>lf", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
				{ "<space>lr", "<cmd>Telescope registers<cr>", desc = "registers" },
				{ "<space>lm", "<cmd>Telescope marks<cr>", desc = "marks" },
				{ "<space>ll", "<cmd>Telescope resume<cr>", desc = "last search" },
			},
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
									["<C-e>"] = ctrlsf_search_for_term,
								},
							},
						},
						grep_string = {
							mappings = {
								i = {
									["<C-e>"] = ctrlsf_search_for_term,
								},
							},
						},
					},
				})

				telescope.load_extension("fzf")
				telescope.load_extension("projects")
				telescope.load_extension("file_browser")
				telescope.load_extension("ui-select")
			end,
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
				"nvim-telescope/telescope-file-browser.nvim",
				"dbakker/vim-projectroot",
				"ahmedkhalf/project.nvim",
				"nvim-telescope/telescope-fzf-native.nvim",
				"benfowler/telescope-luasnip.nvim",
				"nvim-telescope/telescope-ui-select.nvim",
			},
		},
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	{
		"benfowler/telescope-luasnip.nvim",
	},
	{
		"LukasPietzschmann/telescope-tabs",
		dependencies = { "nvim-telescope/telescope.nvim" },
		opts = {},
	},
	{
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
		end,
	},

	{
		"airblade/vim-rooter",
		config = function()
			vim.g.rooter_silent_chdir = 1
		end,
	},
}
