local target_keys = "asdfghjkletovxpzwciubrnym;,ASDFGHJKLETOVXPZWCIUBRNYM"

vim.pack.add({ "https://github.com/smoka7/hop.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("hop").setup({
			keys = target_keys,
			quit_key = "q",
		})

		vim.api.nvim_create_user_command("HopOverwinF", function()
			---@type number|string
			local char = vim.fn.getchar()
			char = type(char) == "number" and vim.fn.nr2char(char) or char

			if char:match("%s") then
				return
			end

			---@type string
			local pattern
			if char:match("%a") then
				---@type string
				local case_flag = (char:match("%l")) and "\\c" or ""
				pattern = "\\v" .. case_flag .. "(<|_@<=)" .. char
			elseif char:match("%p") then
				pattern = [[\V]] .. vim.fn.escape(char, "\\")
			else
				pattern = char
			end

			require("hop").hint_patterns({
				current_line_only = false,
				multi_windows = true,
				hint_position = require("hop.hint").HintPosition.BEGIN,
			}, pattern)
		end, { desc = "Hop to words starting with input character" })
	end,
})
