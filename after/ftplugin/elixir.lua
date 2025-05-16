local keymap = require("ao.keymap")
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

local function open_test_file()
	local current_file = vim.fn.expand("%:p")

	if current_file:match("_test%.exs$") then
		local impl_file = current_file:gsub("_test%.exs$", ".ex")

		if vim.fn.filereadable(impl_file) == 1 then
			vim.cmd("vsplit " .. impl_file)
		else
			vim.notify("Implementation file not found: " .. impl_file, vim.log.levels.WARN)
		end
	else
		local test_file = current_file:gsub("%.ex$", "_test.exs")

		if vim.fn.filereadable(test_file) == 1 then
			vim.cmd("vsplit " .. test_file)
		else
			vim.notify("Test file not found: " .. test_file, vim.log.levels.WARN)
		end
	end
end

keymap.add({
	{ "=", force_format, desc = "Format file", mode = { "n" }, buffer = true },
	{ "ft", open_test_file, desc = "Open test file", mode = { "n" }, buffer = true },
})
