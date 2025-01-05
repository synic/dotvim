local utils = require("ao.utils")
local themes = require("ao.modules.themes")

local M = {}

local function search_cwd()
	local cwd = utils.get_buffer_cwd()
	require("fzf-lua")["live_grep"]({ cwd = cwd })
end

local function find_files_cwd()
	local cwd = utils.get_buffer_cwd()
	require("fzf-lua")["files"]({ cwd = cwd })
end

M.plugin_specs = {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Fzf", "FzfLua" },
		opts = function()
			local actions = require("fzf-lua").actions
			local defaults = require("fzf-lua").defaults

			local opts = {
				fzf_opts = { ["--layout"] = "default" },
				winopts = {
					width = 0.8,
					height = 0.9,
					preview = {
						hidden = "nohidden",
						vertical = "up:45%",
						horizontal = "right:50%",
						layout = "flex",
						flip_columns = 120,
						delay = 10,
						winopts = { number = false },
					},
					backdrop = 100,
				},
				lsp = {
					jump_to_single_result = true,
					jump_to_single_result_action = actions.file_edit,
				},
				buffers = {
					keymap = { builtin = { ["<C-d>"] = false } },
					actions = { ["ctrl-x"] = false, ["ctrl-d"] = { actions.buf_del, actions.resume } },
				},
				keymap = { builtin = { true, ["<Esc>"] = "hide" } },
				files = {
					cwd_prompt = false,
					actions = {
						["ctrl-r"] = {
							function()
								local config = require("fzf-lua").config
								local resume_data = config.__resume_data
								if resume_data then
									local cwd = resume_data.opts.cwd
									require("fzf-lua")["live_grep"]({ cwd = cwd })
								else
									vim.notify("Resume data not found", vim.log.levels.WARN)
								end
							end,
						},
					},
				},
				fzf_colors = {
					["fg"] = { "fg", "TelescopeNormal" },
					["bg"] = { "bg", "TelescopeNormal" },
					["hl"] = { "fg", "TelescopeMatching" },
					["fg+"] = { "fg", "TelescopeSelection" },
					["bg+"] = { "bg", "TelescopeSelection" },
					["hl+"] = { "fg", "TelescopeMatching" },
					["info"] = { "fg", "TelescopeMultiSelection" },
					["border"] = { "fg", "TelescopeBorder" },
					["gutter"] = "-1",
					["query"] = { "fg", "TelescopePromptNormal" },
					["prompt"] = { "fg", "TelescopePromptPrefix" },
					["pointer"] = { "fg", "TelescopeSelectionCaret" },
					["marker"] = { "fg", "TelescopeSelectionCaret" },
					["header"] = { "fg", "TelescopeTitle" },
				},
			}

			local prompt_map = {
				["rg> "] = "search> ",
				["awesome colorschemes> "] = "remote themes> ",
				["colorschemes> "] = "themes> ",
			}

			-- make all the prompts lowercase, they look goofy to me they have multiple words, but only the first is
			-- capatalized, for example `Colorschemes>'
			for key, conf in pairs(defaults) do
				if conf.prompt then
					local prompt = prompt_map[string.lower(conf.prompt)] or conf.prompt
					opts = vim.tbl_deep_extend("keep", opts, { [key] = { prompt = string.lower(prompt) } })
				end
			end

			return opts
		end,
		config = function(_, opts)
			require("fzf-lua").setup(opts)
			vim.cmd("FzfLua register_ui_select")
		end,
		keys = {
			{ "<leader>sd", search_cwd, desc = "Search in buffer's directory" },
			{ "<leader>sS", "<cmd>FzfLua spell_suggest<cr>", desc = "Spelling suggestions" },
			{ "<leader>sR", "<cmd>FzfLua registers<cr>", desc = "Registers" },
			{ "<leader>sl", "<cmd>FzfLua marks<cr>", desc = "Marks" },
			{ "<leader>sB", "<cmd>FzfLua builtin<cr>", desc = "List pickers" },
			{ "<leader>sb", "<cmd>FzfLua blines<cr>", desc = "Search buffer" },
			{ "<leader>.", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },

			-- buffers
			{ "<leader>bb", "<cmd>FzfLua buffers<cr>", desc = "Show buffers" },
			{ "<leader>bs", "<cmd>FzfLua blines<cr>", desc = "Search buffer" },

			-- files
			{ "<leader>ff", find_files_cwd, desc = "Find files" },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
			{ "<leader>fs", search_cwd, desc = "Search files in current dir" },

			-- spellcheck
			{ "<localleader>s", "<cmd>FzfLua spell_suggest<cr>", desc = "Spelling suggestions" },

			-- themes
			{ "<leader>st", themes.colorscheme_picker, desc = "List themes" },

			-- misq
			{ "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Search quickfix" },
		},
	},
}

return M
