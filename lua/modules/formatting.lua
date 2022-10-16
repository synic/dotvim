return function(use)
	use({
		"mhartington/formatter.nvim",
		config = function()
			local util = require("formatter.util")

			require("formatter").setup({
				logging = true,
				log_level = vim.log.levels.WARN,
				filetype = {
					lua = {
						require("formatter.filetypes.lua").stylua,
					},
					typescript = {
						require("formatter.filetypes.typescript").prettier,
					},
					python = {
						require("formatter.filetypes.python").black,
					},

					["*"] = {
						function(pattern, replacement, flags)
							local cmd = vim.fn.has("macunix") and "gsed" or "sed"
							return {
								exe = cmd,
								args = {
									"--in-place",
									util.quote_cmd_arg(util.wrap_sed_replace(pattern, replacement, flags)),
								},
								stdin = false,
							}
						end,
					},
				},
			})

			vim.api.nvim_create_autocmd("BufWritePost", { pattern = "*", command = "FormatWrite" })
		end,
	})
end
