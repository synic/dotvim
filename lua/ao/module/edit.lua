local keymap = require("ao.keymap")
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

local function copy_normalized_block()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" then
		return
	end

	vim.cmd([[silent normal! "xy]])
	local text = vim.fn.getreg("x")
	local lines = vim.split(text, "\n", { plain = true })

	local converted = {}
	for _, line in ipairs(lines) do
		local l = line:gsub("\t", "  ")
		table.insert(converted, l)
	end

	local min_indent = math.huge
	for _, line in ipairs(converted) do
		if line:match("[^%s]") then
			local indent = #(line:match("^%s*"))
			min_indent = math.min(min_indent, indent)
		end
	end
	min_indent = min_indent == math.huge and 0 or min_indent

	local result = {}
	for _, line in ipairs(converted) do
		if line:match("^%s*$") then
			table.insert(result, "")
		else
			local processed = line:sub(min_indent + 1)
			processed = processed:gsub("^%s+", function(spaces)
				return string.rep("  ", math.floor(#spaces / 2))
			end)
			table.insert(result, processed)
		end
	end

	local normalized = table.concat(result, "\n")
	vim.fn.setreg("+", normalized)
	vim.notify("Copied normalized text to clipboard")
end

-- set up keys
keymap.add({
	{ "<leader>cp", "<cmd>Lazy<cr>", desc = "Plugin manager" },
	{ "<leader>cPu", "<cmd>Lazy update<cr>", desc = "Update plugins" },
	{ "<leader>cPs", "<cmd>Lazy sync<cr>", desc = "Sync plugins" },
	{ "<leader>wM", zoom_toggle, desc = "Zoom window" },
	{ "<leader>y", copy_normalized_block, mode = { "v" }, desc = "Copy normalized block" },
})

---@type PluginModule
local plugins = {
	-- surround plugin
	{
		"kylechui/nvim-surround",
		version = "^3.0.0",
		event = "VeryLazy",

		opts = {
			surrounds = {
				["%"] = {
					add = function()
						if vim.bo.filetype == "elixir" then
							return {
								"%{",
								"}",
							}
						end
					end,
				},
			},
		},
	},

	-- joining and splitting
	{
		"Wansmer/treesj",
		keys = {
			{ "<localleader>j", "<cmd>lua require('treesj').split()<cr>", desc = "Split" },
			{ "<localleader>J", "<cmd>lua require('treesj').join()<cr>", desc = "Join" },
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			max_join_length = 2000, -- just do it, and let the formatter worry about it being too long
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

	-- markdown renderer
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown", "Avante" },
		},
		ft = { "markdown", "Avante" },
	},

	-- annotations
	{
		"danymat/neogen",
		dependencies = { "saadparwaiz1/cmp_luasnip" },
		opts = {
			snippet_engine = "luasnip",
		},
		keys = {
			{ "<localleader>g", "<cmd>lua require('neogen').generate()<cr>", desc = "Generate annotations" },
		},
	},
}

-- if wakatime is installed/enabled but the configuration file doesn't exist,
-- it becomes very annoying. Only try to enable it if the config file is already present.
local wakatime_config = { "wakatime/vim-wakatime", event = "VeryLazy" }
local wakatime_config_path = vim.fs.joinpath(os.getenv("HOME"), ".wakatime.cfg")

if uv.fs_stat(wakatime_config_path) then
	plugins[#plugins + 1] = wakatime_config
end

return plugins
