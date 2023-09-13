local utils = require("ao.core.utils")

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

vim.api.nvim_set_keymap("n", "<leader>Pl", ":Lazy<cr>", { desc = "list plugins" })
vim.api.nvim_set_keymap("n", "<leader>Pu", ":Lazy update<cr>", { desc = "update plugins" })
vim.api.nvim_set_keymap("n", "<leader>Ps", ":Lazy sync<cr>", { desc = "sync plugins" })
vim.api.nvim_set_keymap("n", "<leader>wM", ":ZoomToggle<cr>", { desc = "zoom window" })

local function base_plugins()
  return {
    "ConradIrwin/vim-bracketed-paste",

    {
      "s1n7ax/nvim-terminal",
      keys = {
        { "<leader>'", "<cmd>lua NTGlobal['terminal']:toggle()<cr>", desc = "toggle terminal" },
      },
      opts = {
        disable_default_keymaps = true,
      },
    },
  }
end

local wakatime_config = {
  "wakatime/vim-wakatime",
}

local wakatime_config_path = utils.join_paths(os.getenv("HOME"), ".wakatime.cfg")
local plugins = base_plugins()

if vim.loop.fs_stat(wakatime_config_path) then
  plugins = utils.table_concat(plugins, wakatime_config)
end

return plugins
