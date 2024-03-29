local utils = require("ao.utils")
local interface = require("ao.modules.interface")
local projects = require("ao.modules.projects")

local M = {}

local function telescope_narrow_grep(prompt_bufnr)
	local builtin = require("telescope.builtin")
	local actions = require("telescope.actions")
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)

	local root = projects.find_buffer_root()
	local prompt = current_picker:_get_prompt()
	actions.close(prompt_bufnr)

	if not prompt or prompt == "" then
		vim.notify("no prompt to narrow", vim.log.levels.WARN)
		return
	end

	vim.notify('narrowing to: "' .. prompt .. '"')

	builtin.grep_string({ cwd = (root or "."), search = prompt })
end

local telescope_tabs_entry_formatter = function(tabnr, _, _, _, is_current)
	local name = interface.get_tab_name(tabnr)
	local display = "[No Name]"

	if name and name ~= "" then
		display = name
	else
		display = require("tabby.feature.tab_name").get(tabnr)
	end

	if vim.fn.gettabvar(tabnr, "project_dir") ~= "" then
		display = "project: " .. display
	end

	return string.format("%d: %s%s", tabnr, display, is_current and " <" or "")
end

local function telescope_search_cwd()
	require("telescope.builtin").live_grep({ cwd = utils.get_buffer_cwd() })
end

local function telescope_find_files_cwd()
	require("telescope.builtin").find_files({ cwd = utils.get_buffer_cwd() })
end

local function ctrlsf_search_for_term(prompt_bufnr)
	local actions = require("telescope.actions")
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)

	local prompt = current_picker:_get_prompt()
	actions.close(prompt_bufnr)
	if not prompt then
		vim.notify("Edit: no search terms", vim.log.levels.WARN)
		return
	end
	vim.cmd.CtrlSF(prompt)
end

M.plugin_specs = {
	-- fuzzy finder and list manager
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			-- search
			{ "<leader>sf", telescope_search_cwd, desc = "Search in buffer's directory" },
			{ "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
			{ "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
			{ "<leader>sl", "<cmd>Telescope marks<cr>", desc = "Marks" },
			{ "<leader>sB", "<cmd>Telescope builtin<cr>", desc = "List pickers" },
			{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },
			{ "<leader>sn", "<cmd>Telescope notify<cr>", desc = "Notifications" },
			{ "<leader>.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },

			-- buffers
			{ "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Show buffers" },
			{ "<leader>bs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },

			-- files
			{ "<leader>ff", telescope_find_files_cwd, desc = "Find files" },
			{ "<leader>fr", "<cmd>Telescope recent_files pick<cr>", desc = "Recent files" },
			{ "<leader>fs", telescope_search_cwd, desc = "Search files in current dir" },

			-- themes
			{ "<leader>st", "<cmd>ColorSchemePicker<cr>", desc = "List themes" },
		},
		cmd = "Telescope",
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["//"] = actions.file_vsplit,
							["--"] = actions.file_split,
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
					["telescope-tabs"] = {
						prompt_title = "Layouts",
					},
				},
				pickers = {
					buffers = {
						sort_mru = true,
						ignore_current_buffer = true,
						layout_config = {
							preview_width = 0.55,
						},
					},
					live_grep = {
						mappings = {
							i = {
								["<C-e>"] = ctrlsf_search_for_term,
								["<C-;>"] = telescope_narrow_grep,
							},
							n = {
								["e"] = ctrlsf_search_for_term,
								[";"] = telescope_narrow_grep,
							},
						},
					},
					grep_string = {
						layout_config = {
							preview_width = 0.5,
						},
					},
					colorscheme = {
						enable_preview = true,
					},
					find_files = {
						layout_config = {
							preview_width = 0.55,
						},
					},
					["telescope-tabs"] = {
						layout_config = { width = 0.4, height = 0.3 },
					},
				},
			})

			telescope.load_extension("ui-select")
			telescope.load_extension("fzf")
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				enabled = vim.fn.executable("make") == 1,
			},
		},
	},

	{
		"benfowler/telescope-luasnip.nvim",
		dependences = { "telescope.nvim" },
		{ "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
	},

	{
		"debugloop/telescope-undo.nvim",
		dependences = { "telescope.nvim" },
		keys = {
			{ "<leader>tu", "<cmd>Telescope undo<cr>", desc = "Undo tree" },
		},
	},

	{
		"smartpde/telescope-recent-files",
		dependencies = { "telescope.nvim" },
		keys = {
			{ "<leader>,", "<cmd>Telescope recent_files pick<cr>", desc = "Recent files" },
		},
	},

	{
		"LukasPietzschmann/telescope-tabs",
		opts = {
			entry_formatter = telescope_tabs_entry_formatter,
			entry_ordinal = telescope_tabs_entry_formatter,
			show_preview = false,
		},
		dependencies = { "telescope.nvim" },
		keys = {

			-- layouts/windows
			{ "<leader>ll", "<cmd>Telescope telescope-tabs list_tabs<cr>", desc = "List layouts" },
		},
	},
}

return M
