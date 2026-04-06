vim.pack.add({ "https://github.com/folke/which-key.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local wk = require("which-key")
		local keymap = require("modules.keymap")
		wk.setup({
			preset = "modern",
			plugins = { spelling = true },
			icons = { mappings = false },
		})
		wk.add(keymap.categories)
	end,
})
