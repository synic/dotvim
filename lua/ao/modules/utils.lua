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
  { "<leader>cp", "<cmd>Lazy<cr>", desc = "plugin manager" },
  { "<leader>cPu", "<cmd>Lazy update<cr>", desc = "update plugins" },
  { "<leader>cPs", "<cmd>Lazy sync<cr>", desc = "sync plugins" },
  { "<leader>wM", "<cmd>ZoomToggle<cr>", desc = "zoom window" },
})

local plugins = {
  -- automatically enter paste mode
  { "ConradIrwin/vim-bracketed-paste", lazy = false },

  -- surround plugin
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  {
    "terrortylor/nvim-comment",
    opts = {},
    config = function(opts)
      require("nvim_comment").setup(opts)
    end,
  },

  -- display undoo list
  {
    "mbbill/undotree",
    keys = {
      { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "undo tree" },
    },
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  "christoomey/vim-tmux-navigator",
}

local wakatime_config = { "wakatime/vim-wakatime", event = { "BufReadPre", "BufNewFile" } }

local wakatime_config_path = utils.join_paths(os.getenv("HOME"), ".wakatime.cfg")

if vim.loop.fs_stat(wakatime_config_path) then
  plugins = utils.table_concat(plugins, wakatime_config)
end

return plugins
