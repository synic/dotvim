if not vim.g.neovide then
	return {}
end
local transparency = 0.98

local alpha = function()
	return string.format("%x", math.floor(255 * (vim.g.transparency or transparency)))
end

vim.g.neovide_input_use_logo = 1
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_floating_corner_radius = 10
vim.g.neovide_padding_top = 2
vim.g.neovide_remember_window_size = true
vim.g.neovide_input_macos_option_key_is_meta = "only_left"
vim.g.neovide_transparency = transparency
vim.g.neovide_normal_opacity = transparency
vim.o.winblend = 20

vim.g.neovide_background_color = "#0f1117" .. alpha()

return {}
