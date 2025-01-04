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
		opts = function()
			local fzf = require("fzf-lua")

			return {
				winopts = {
					backdrop = 100,
				},
			}
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
