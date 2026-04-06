vim.pack.add({ "https://github.com/neogitorg/neogit" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("neogit").setup({
			{
				kind = "vsplit",
				auto_show_console = false,
				remember_settings = true,
				commit_editor = { kind = "split" },
				commit_select_view = { kind = "split" },
				log_view = { kind = "split" },
				rebase_editor = { kind = "split" },
				reflog_view = { kind = "split" },
				merge_editor = { kind = "split" },
				description_editor = { kind = "split" },
				tag_editor = { kind = "split" },
				preview_buffer = { kind = "split" },
				popup = { kind = "split" },
				auto_refresh = true,
				filewatcher = {
					interval = 1000,
					enabled = true,
				},
				commit_view = {
					kind = "vsplit",
					verify_commit = vim.fn.executable("gpg") == 1,
				},
			},
		})
	end,
})
