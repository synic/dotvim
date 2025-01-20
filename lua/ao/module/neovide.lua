if not vim.g.neovide then
	return {}
end

vim.g.neovide_input_use_logo = 1
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_floating_corner_radius = 10
vim.g.neovide_remember_window_size = true
vim.g.neovide_input_macos_option_key_is_meta = "only_left"
vim.g.neovide_transparency = 0.98
vim.o.winblend = 20

return {}
