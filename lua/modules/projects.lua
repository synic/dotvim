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

local function telescope_search_for_term(prompt_bufnr)
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
		builtin.find_files()
	end
end

return {
	{ "dbakker/vim-projectroot", lazy = false },
	{
		{
			"nvim-telescope/telescope.nvim",
			lazy = false,

			keys = {
				{
					"<space>bb",
					"<cmd>lua require('telescope.builtin').buffers({ sort_mru=true, sort_lastused=true, icnore_current_buffer=true })<cr>",
					desc = "Show buffers",
				},
				{ "<space>ph", telescope_project_files, desc = "Project files" },
				{ "<space>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
				{ "<space>sp", "<cmd>Telescope live_grep<cr>", desc = "Search in project files" },
				{ "<space>rl", "<cmd>Telescope resume<cr>", desc = "Show last search" },
				{ "<space>sd", telescope_search_cwd, desc = "Search in current directory" },
				{ "<space>gB", "<cmd>Telescope git_branches<cr>", desc = "Show git branches" },
				{ "<space>gS", "<cmd>Telescope git_stash<cr>", desc = "Show git stashes" },
				{ "<space>ml", "<cmd>Telescope marks<cr>", desc = "Show marks" },
				{ "<space>rr", "<cmd>Telescope registers<cr>", desc = "Show registers" },
				{ "<space>ss", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
				{ "<space>*", telescope_search_star, desc = "Search for term globally" },
				{ "<space>pr", telescope_load_projects, desc = "Recent projects" },
				{ "<space>ll", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "List layouts" },
				{ "<space>ls", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "Snippets" },
				{ "<space>ln", telescope_new_tab_with_projects, desc = "New layout" },
				{ "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code actions" },
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
									["<C-e>"] = telescope_search_for_term,
								},
							},
						},
						grep_string = {
							mappings = {
								i = {
									["<C-e>"] = telescope_search_for_term,
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
