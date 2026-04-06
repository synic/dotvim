vim.pack.add({ "https://github.com/folke/flash.nvim" })
local target_keys = "asdfghjkletovxpzwciubrnym;,ASDFGHJKLETOVXPZWCIUBRNYM"

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("flash").setup({
			modes = {
				char = { enabled = false },
			},
			labels = target_keys,
		})
	end,
})
