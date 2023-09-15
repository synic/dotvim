local keymap = require("ao.keymap")
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
keymap.lazy()
keymap.zoom_toggle()

local plugins = {
  "ConradIrwin/vim-bracketed-paste",
}

local wakatime_config = { "wakatime/vim-wakatime" }

local wakatime_config_path = utils.join_paths(os.getenv("HOME"), ".wakatime.cfg")

if vim.loop.fs_stat(wakatime_config_path) then
  plugins = utils.table_concat(plugins, wakatime_config)
end

return plugins
