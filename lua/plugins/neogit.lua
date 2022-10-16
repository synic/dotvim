local ok, neogit = pcall(require, "neogit")

if not ok then
	return
end

neogit.setup({
	kind = "vsplit",
})

vim.keymap.set("n", "<space>gs", ":Neogit<cr>")
