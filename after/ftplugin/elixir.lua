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

local function open_test_file(mode)
	if mode == nil or mode == "" then
		mode = "edit"
	end

	local current_file = vim.fn.expand("%:p")

	if current_file:match("_test%.exs$") then
		local impl_file = current_file:gsub("_test%.exs$", ".ex")

		if vim.fn.filereadable(impl_file) == 1 then
			vim.cmd(mode .. " " .. impl_file)
		else
			vim.notify("Implementation file not found: " .. impl_file, vim.log.levels.WARN)
		end
	else
		local test_file = current_file:gsub("%.ex$", "_test.exs")

		if vim.fn.filereadable(test_file) == 1 then
			vim.cmd(mode .. " " .. test_file)
		else
			vim.notify("Test file not found: " .. test_file, vim.log.levels.WARN)
		end
	end
end

keymap.add({
	{ "=", force_format, desc = "Format file", mode = { "n" }, buffer = true },
	{
		"<localleader>/",
		function()
			open_test_file("vsplit")
		end,
		mode = { "n" },
		desc = "Toggle test file in vsplit",
		buffer = true,
	},
	{ "<localleader>.", open_test_file, desc = "Toggle test file", mode = { "n" }, buffer = true },
})
