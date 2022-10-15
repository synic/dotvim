vim.keymap.set("n", "<leader>r", function()
	return ":IncRename " --.. vim.fn.expand("<cword>")
end, { expr = true })
