local utils = require("ao.utils")

vim.cmd([[
	function! s:ZoomToggle() abort
		if exists('t:zoomed') && t:zoomed
			execute t:zoom_winrestcmd
			let t:zoomed = 0
		else
			let t:zoom_winrestcmd = winrestcmd()
			resize
			vertical resize
			let t:zoomed = 1
		endif
	endfunction
	command! ZoomToggle call s:ZoomToggle()
]])

-- set up keys
utils.map_keys({
  { "<leader>cp", "<cmd>Lazy<cr>", desc = "Plugin manager" },
  { "<leader>cPu", "<cmd>Lazy update<cr>", desc = "Update plugins" },
  { "<leader>cPs", "<cmd>Lazy sync<cr>", desc = "Sync plugins" },
  { "<leader>wM", "<cmd>ZoomToggle<cr>", desc = "Zoom window" },
})

local plugins = {
  -- automatically enter paste mode
  { "ConradIrwin/vim-bracketed-paste", event = "VeryLazy" },

  -- surround plugin
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  {
    "terrortylor/nvim-comment",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    config = function(opts)
      require("nvim_comment").setup(opts)
    end,
  },

  -- display undoo list
  {
    "mbbill/undotree",
    keys = {
      { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
    },
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  "christoomey/vim-tmux-navigator",

  {
    "ellisonleao/carbon-now.nvim",
    lazy = true,
    cmd = "CarbonNow",
    keys = {
      { mode = "v", "<leader>xc", "<cmd>CarbonNow<cr>", desc = "Create carbonnow snippet" },
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
local wakatime_config = { "wakatime/vim-wakatime", event = { "BufReadPre", "BufNewFile" }, lazy = true }
local wakatime_config_path = utils.join_paths(os.getenv("HOME"), ".wakatime.cfg")

if vim.loop.fs_stat(wakatime_config_path) then
  plugins = utils.table_concat(plugins, wakatime_config)
end

return plugins
