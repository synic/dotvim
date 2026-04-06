vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		require("fidget").setup({
			notification = { window = { winblend = 20 } },
			progress = {
				suppress_on_insert = true,
				ignore_done_already = false,
				ignore_empty_message = true,
				display = {
					done_ttl = 1,
					skip_history = false,
					format_message = function(msg)
						local message = msg.message

						if not message then
							message = msg.done and "Completed" or "In progress..."
						end
						if msg.percentage ~= nil then
							message = string.format("%s (%.0f%%)", message, msg.percentage)
						end

						-- hack to supress long messages nextls sometimes outputs
						if msg.lsp_client.config.name == "nextls" then
							message = message:gsub("for folder", "for")
							message = message:gsub("[%w%-%._/\\]+/([%w%-%._]+)[%p]?", "%1")
							message = message:gsub("\\[%w%-%._/\\]+\\([%w%-%._]+)[%p]?", "%1")
						end

						return message
					end,
					format_annote = function(msg)
						local annote = msg.title

						if not annote then
							return nil
						end

						-- hack to supress long messages nextls sometimes outputs
						if msg.lsp_client.config.name == "nextls" and msg.done then
							return ""
						end
						return annote
					end,
				},
			},
		})
	end,
})
