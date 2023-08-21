vim.api.nvim_set_option("guifont", "Hack:h10")

-- neovide options
vim.g.neovide_remember_window_size = false
vim.g.neovide_remember_window_position = false

local f = require("core.functions")

f.ensure_package_manager()

require("lazy").setup('modules')
