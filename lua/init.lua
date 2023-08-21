vim.api.nvim_set_option("guifont", "Hack:h10")

local f = require("core.functions")
f.ensure_package_manager()
require("lazy").setup("modules")
