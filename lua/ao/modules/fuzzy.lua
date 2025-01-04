local utils = require("ao.utils")
local themes = require("ao.modules.themes")
local interface = require("ao.modules.interface")

local M = {}

local telescope_tabs_entry_formatter = function(tabnr, _, _, _, is_current)
	local name = interface.get_tab_name(tabnr)
	local display = "[No Name]"

	if name and name ~= "" then
		display = "project: " .. name
	else
		display = require("tabby.feature.tab_name").get(tabnr)
	end

	return string.format("%d: %s%s", tabnr, display, is_current and " <" or "")
end

local function telescope_search_cwd()
	require("telescope.builtin").live_grep({ cwd = utils.get_buffer_cwd() })
end

local function telescope_find_files_cwd()
	require("telescope.builtin").find_files({ cwd = utils.get_buffer_cwd() })
end

M.plugin_specs = {
	-- fuzzy finder and list manager
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			-- search
			{ "<leader>sd", telescope_search_cwd, desc = "Search in buffer's directory" },
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

			-- spellcheck
			{
				"<localleader>s",
				function()
					require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor())
				end,
				desc = "Spelling suggestions",
			},

			-- themes
			{ "<leader>st", themes.colorscheme_picker, desc = "List themes" },

			-- misq
			{ "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Search quickfix" },
		},
		cmd = "Telescope",
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					file_ignore_patterns = { "%_templ.go", "node_modules", ".git", "bruno" },
					mappings = {
						i = {
							["//"] = actions.file_vsplit,
							["--"] = actions.file_split,
							["<c-space>"] = actions.to_fuzzy_refine,
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
					grep_string = {
						layout_config = {
							preview_width = 0.5,
						},
					},
					colorscheme = {
						enable_preview = true,
					},
					find_files = {
						hidden = true,
						layout_config = {
							preview_width = 0.55,
						},
					},
					["telescope-tabs"] = {
						layout_config = { width = 0.4, height = 0.3 },
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			local has_flash, flash = pcall(require, "flash")

			if has_flash then
				local function flash_jump(prompt_bufnr)
					---@diagnostic disable-next-line: missing-fields
					flash.jump({
						pattern = "^",
						label = { after = { 0, 0 } },
						search = {
							mode = "search",
							exclude = {
								function(win)
									return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
								end,
							},
						},
						action = function(match)
							local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
							picker:set_selection(match.pos[1] - 1)
						end,
					})
				end
				opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
					mappings = {
						n = { s = flash_jump },
						i = { ["<c-s>"] = flash_jump },
					},
				})
			end

			telescope.setup(opts)
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
		keys = { { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" } },
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
