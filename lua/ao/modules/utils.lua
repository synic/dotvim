local utils = require("ao.utils")
local uv = vim.uv or vim.loop

local function zoom_toggle()
	if vim.t.zoomed then
		vim.fn.execute(vim.t.zoom_winrestcmd)
		vim.t.zoomed = false
	else
		vim.t.zoom_winrestcmd = vim.fn.winrestcmd()
		vim.t.zoomed = true
		vim.cmd("resize")
		vim.cmd("vertical resize")
	end
end

-- set up keys
utils.map_keys({
	{ "<leader>cp", "<cmd>Lazy<cr>", desc = "Plugin manager" },
	{ "<leader>cPu", "<cmd>Lazy update<cr>", desc = "Update plugins" },
	{ "<leader>cPs", "<cmd>Lazy sync<cr>", desc = "Sync plugins" },
	{ "<leader>wM", zoom_toggle, desc = "Zoom window" },
})

local plugins = {
	-- automatically set tabstop settings, etc
	{ "tpope/vim-sleuth", event = "VeryLazy" },

	-- automatically enter paste mode
	{ "ConradIrwin/vim-bracketed-paste", event = "VeryLazy" },

	-- surround plugin
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", config = true },

	-- commenting blocks
	{ "terrortylor/nvim-comment", main = "nvim_comment", config = true, event = "VeryLazy" },

	-- joining and splitting
	{
		"Wansmer/treesj",
		keys = {
			{ "gj", "<cmd>lua require('treesj').split()<cr>", desc = "Split" },
			{ "gJ", "<cmd>lua require('treesj').join()<cr>", desc = "Join" },
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			use_default_keymaps = false,
		},
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		event = "VeryLazy",
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- create an image of your code snippet (to post on Twitter, etc)
	{
		"ellisonleao/carbon-now.nvim",
		cmd = "CarbonNow",
		keys = {
			{
				mode = "v",
				"<leader>xc",
				-- purposely not using <cmd> here, for some reason it
				-- doesn't seem to work with visual mode
				":CarbonNow<cr>",
				desc = "Create carbonnow snippet",
			},
		},
		opts = {
			open_cmd = "open",
			options = {
				bg = "#204678",
				drop_shadow_blur = "68px",
				drop_shadow = false,
				drop_shadow_offset_y = "20px",
				font_family = "Hack",
				font_size = "15px",
				line_height = "133%",
				line_numbers = true,
				theme = "verminal",
				titlebar = "",
				watermark = false,
				width = "680",
				window_theme = "verminal",
			},
		},
	},
}

-- if wakatime is installed/enabled but the configuration file doesn't exist,
-- it becomes very annoying. Only try to enable it if the config file is already present.
local wakatime_config = { "wakatime/vim-wakatime", event = "VeryLazy" }
local wakatime_config_path = utils.join_paths(os.getenv("HOME"), ".wakatime.cfg")

if uv.fs_stat(wakatime_config_path) then
	plugins[#plugins + 1] = wakatime_config
end

return plugins
