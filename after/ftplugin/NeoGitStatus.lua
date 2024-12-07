vim.api.nvim_buf_set_keymap(0, "n", "g,", "", {
	desc = "Open GitHub in browser",
	callback = function()
		-- Get the remote URL
		local handle, err = io.popen("git config --get remote.origin.url")
		if not handle then
			vim.notify("Failed to get git remote: " .. (err or "unknown error"), vim.log.levels.ERROR)
			return
		end
		local result = handle:read("*a")
		handle:close()

		if not result or result == "" then
			vim.notify("No git remote URL found", vim.log.levels.ERROR)
			return
		end

		-- Convert SSH URL to HTTPS URL if needed
		result = result:gsub("^git@github.com:", "https://github.com/")
		result = result:gsub("%.git\n$", "")

		-- Get current branch
		handle, err = io.popen("git branch --show-current")
		if not handle then
			vim.notify("Failed to get git branch: " .. (err or "unknown error"), vim.log.levels.ERROR)
			return
		end
		local branch = handle:read("*a")
		handle:close()

		if not branch or branch == "" then
			vim.notify("No git branch found", vim.log.levels.ERROR)
			return
		end
		branch = branch:gsub("\n$", "")

		-- If we're already on main/master, compare with HEAD
		if branch == "main" or branch == "master" then
			vim.notify("Already on main/master branch", vim.log.levels.WARN)
			return
		end

		-- Construct compare URL
		local url = string.format("%s/compare/main...%s", result, branch)

		-- Determine OS and open URL
		local os_name = vim.loop.os_uname().sysname
		local open_cmd = os_name == "Darwin" and "open" or "xdg-open"
		local success, err_msg = os.execute(string.format("%s '%s'", open_cmd, url))
		if not success then
			vim.notify("Failed to open URL: " .. (err_msg or "unknown error"), vim.log.levels.ERROR)
		end
	end,
})

vim.defer_fn(function()
	vim.cmd.normal("2")
end, 200)
