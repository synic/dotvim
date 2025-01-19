local key = require("ao.core.key")
local opt = vim.opt_local

opt.expandtab = true
opt.softtabstop = 2
opt.tabstop = 2
opt.shiftwidth = 2
opt.textwidth = 0
opt.cindent = true
opt.autoindent = true
opt.smartindent = true

local function force_format()
	vim.notify("Elixir: running mix format and restarting the lsp")
	vim.cmd("silent !mix format")
	vim.cmd.LspRestart()
end

key.map({
	{ "=", force_format, desc = "Format file", mode = { "n" }, buffer = true },
})
