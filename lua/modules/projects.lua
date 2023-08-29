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
				{ "<space>ph", "<cmd>Telescope git_files<cr>", desc = "Project files" },
				{ "<space>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
				{ "<space>sp", "<cmd>Telescope live_grep<cr>", desc = "Search in project files" },
				{ "<space>rl", "<cmd>Telescope resume<cr>", desc = "Show last search" },
				{
					"<space>sd",
					"<cmd>lua require('ao.functions').telescope_search_cwd()<cr>",
					desc = "Search in current directory",
				},
				{ "<space>gB", "<cmd>Telescope git_branches<cr>", desc = "Show git branches" },
				{ "<space>gS", "<cmd>Telescope git_stash<cr>", desc = "Show git stashes" },
				{ "<space>ml", "<cmd>Telescope marks<cr>", desc = "Show marks" },
				{ "<space>rr", "<cmd>Telescope registers<cr>", desc = "Show registers" },
				{ "<space>ss", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
				{
					"<space>*",
					"<cmd>lua require('ao.functions').telescope_search_star()<cr>",
					desc = "Search for term globally",
				},
				{
					"<space>pr",
					"<cmd>lua require('ao.functions').telescope_load_projects()<cr>",
					desc = "Recent projects",
				},
				{
					"<space>ll",
					"<cmd>lua require('telescope-tabs').list_tabs()<cr>",
					desc = "List layouts",
				},
				{
					"<space>ls",
					"<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>",
					desc = "Snippets",
				},
				{
					"<space>ln",
					"<cmd>lua require('ao.functions').telescope_new_tab_with_projects()<cr>",
					desc = "New layout",
				},
				{
					"<leader>a",
					"<cmd>lua vim.lsp.buf.code_action()<cr>",
					desc = "Code actions",
				},
			},
			config = function()
				local telescope = require("telescope")
				local functions = require("ao.functions")

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
									["<C-e>"] = functions.telescope_search_for_term,
								},
							},
						},
						grep_string = {
							mappings = {
								i = {
									["<C-e>"] = functions.telescope_search_for_term,
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
