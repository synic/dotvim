local utils = require("ao.utils")
local themes = require("ao.modules.themes")
local interface = require("ao.modules.interface")

local M = {}

local tabs_entry_formatter = function(tabnr, _, _, _, is_current)
	local name = interface.get_tab_name(tabnr)
	local display = "[No Name]"

	if name and name ~= "" then
		display = "project: " .. name
	else
		display = require("tabby.feature.tab_name").get(tabnr)
	end

	return string.format("%d: %s%s", tabnr, display, is_current and " <" or "")
end

local function search_cwd()
	require("telescope.builtin").live_grep({ cwd = utils.get_buffer_cwd() })
end

local function find_files_cwd()
	require("telescope.builtin").find_files({ cwd = utils.get_buffer_cwd() })
end

M.plugin_specs = {
	-- fuzzy finder and list manager
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			-- search
			{ "<leader>sd", search_cwd, desc = "Search in buffer's directory" },
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
			{ "<leader>ff", find_files_cwd, desc = "Find files" },
			{ "<leader>fr", "<cmd>Telescope recent_files pick<cr>", desc = "Recent files" },
			{ "<leader>fs", search_cwd, desc = "Search files in current dir" },

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
			local state = require("telescope.actions.state")
			local builtin = require("telescope.builtin")
			local config = require("telescope.config")

			local file_ignore_patterns = { "%_templ.go", "node_modules", ".git", "bruno" }
			local live_grep_additional_args = {}

			local has_flash, flash = pcall(require, "flash")
			local function flash_jump()
				vim.notify("flash.nvim not installed", vim.log.levels.WARN)
			end

			if has_flash then
				function flash_jump(prompt_bufnr)
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
							local picker = state.get_current_picker(prompt_bufnr)
							picker:set_selection(match.pos[1] - 1)
						end,
					})
				end
			end

			return {
				defaults = {
					file_ignore_patterns = file_ignore_patterns,
					mappings = {
						i = {
							["//"] = actions.file_vsplit,
							["--"] = actions.file_split,
							["<c-s>"] = flash_jump,
						},
						n = {
							["s"] = flash_jump,
						},
					},
				},
				pickers = {
					buffers = {
						sort_mru = true,
						ignore_current_buffer = true,
						layout_config = {
							preview_width = 0.55,
							layout_strategy = "current_buffer",
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
						hidden = false,
						layout_config = {
							preview_width = 0.55,
						},
						mappings = {
							i = {
								["//"] = actions.file_vsplit,
								["--"] = actions.file_split,
								["<c-space>"] = actions.to_fuzzy_refine,

								-- toggle hidden files
								["<c-h>"] = function(prompt_bufnr)
									local picker = state.get_current_picker(prompt_bufnr)
									local defaults = config.values
									local pickers = config.pickers
									local prompt_title = "Find Files"
									local prompt = picker:_get_prompt()

									pickers.find_files.hidden = not pickers.find_files.hidden

									if pickers.find_files.hidden then
										prompt_title = "Find Files (+ hidden)"
									end

									pickers.find_files.prompt_title = prompt_title
									defaults.file_ignore_patterns = pickers.find_files.hidden and {}
										or file_ignore_patterns
									config.set_defaults(defaults)
									config.set_pickers(pickers)

									actions.close(prompt_bufnr)
									---@diagnostic disable-next-line: assign-type-mismatch
									builtin.find_files({
										cwd = picker.cwd,
										no_ignore = pickers.find_files.hidden,
										default_text = prompt,
									})
								end,

								-- switch to live_grep
								["<m-r>"] = function(prompt_bufnr)
									local picker = state.get_current_picker(prompt_bufnr)
									local prompt = picker:_get_prompt()
									actions.close(prompt_bufnr)
									builtin.live_grep({ cwd = picker.cwd, default_text = prompt })
								end,
							},
						},
					},
					live_grep = {
						prompt_title = "Search",
						additional_args = live_grep_additional_args,
						mappings = {
							i = {
								["//"] = actions.file_vsplit,
								["--"] = actions.file_split,
								-- toggle hidden files/.gitnore
								["<c-h>"] = function(prompt_bufnr)
									local picker = state.get_current_picker(prompt_bufnr)
									local pickers = config.pickers
									local prompt_title = "Search"
									local prompt = picker:_get_prompt()

									if #live_grep_additional_args == 0 then
										live_grep_additional_args = { "--no-ignore" }
										prompt_title = "Search (+ hidden)"
									else
										live_grep_additional_args = {}
									end

									pickers.live_grep.additional_args = live_grep_additional_args
									pickers.live_grep.prompt_title = prompt_title
									config.set_pickers(pickers)

									actions.close(prompt_bufnr)
									---@diagnostic disable-next-line: assign-type-mismatch
									builtin.live_grep({ cwd = picker.cwd, default_text = prompt })
								end,

								-- switch to find_files
								["<m-r>"] = function(prompt_bufnr)
									local picker = state.get_current_picker(prompt_bufnr)
									local prompt = picker:_get_prompt()
									actions.close(prompt_bufnr)
									builtin.find_files({ cwd = picker.cwd, default_text = prompt })
								end,
							},
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
						layout_config = { width = 0.4, height = 0.3 },
						prompt_title = "Layouts",
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")

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
			entry_formatter = tabs_entry_formatter,
			entry_ordinal = tabs_entry_formatter,
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
