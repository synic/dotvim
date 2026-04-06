local M = {}
-- Open GitBlame
--
-- This function goes through all open buffers, closes any existing gitsigns-blame windows (removing their WinClosed
-- events first), and then opens a new blame window. It also attaches an event to the new blame window to make it so
-- that when blame is closed (either through toggle or through `q`), it puts the cursor back in the window that opened
-- the blame, instead of just focusing whatever window is on the left of the blame.
function M.open_gitblame()
	local current_win = vim.fn.win_getid()

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "gitsigns-blame" then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == buf then
					vim.api.nvim_clear_autocmds({
						event = "WinClosed",
						pattern = tostring(win),
					})
					vim.api.nvim_win_close(win, true)
				end
			end
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "gitsigns-blame",
		callback = function()
			vim.api.nvim_create_autocmd("WinClosed", {
				pattern = tostring(vim.fn.win_getid()),
				callback = function()
					pcall(vim.api.nvim_set_current_win, current_win)
				end,
				once = true,
			})
		end,
		once = true,
	})
	vim.cmd.Gitsigns("blame")
end

function M.git_add()
	vim.cmd("silent !git add %")
	vim.notify("Issued `git add " .. vim.fn.expand("%p") .. "` ...")
end

-- Open Neogit
--
-- This function goes through all the buffers and closes any that are the neogit status buffer, and _then_ opens
-- Neogit. This is because if you open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. Neogit is already open, even if you can't see it.
function M.neogit_open()
	local neogit = require("neogit")
	local root = vim.fs.root(0, { ".git" })

	if not root then
		vim.notify("Could not determine git root", vim.log.levels.WARN)
		return
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype:find("^Neogit") ~= nil then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	neogit.open({ cwd = root })
end

return M
