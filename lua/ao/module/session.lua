local M = {}
local session_dir = vim.fn.stdpath("state") .. "/sessions"
local session_file = session_dir .. "/main_session.vim"
local extra_session_file = session_dir .. "/main_sessionx.vim"

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("SessionSave", { clear = true }),
	callback = function()
		if vim.fn.isdirectory(session_dir) == 0 then
			vim.fn.mkdir(session_dir, "p")
		end
		vim.cmd("mksession! " .. session_file)
		local lines = {}

		local tabpages = vim.api.nvim_list_tabpages()
		local current_nr = vim.api.nvim_get_current_tabpage()

		for _, nr in ipairs(tabpages) do
			vim.api.nvim_set_current_tabpage(nr)
			table.insert(lines, "tabnext " .. nr)

			local has_tcd = vim.fn.haslocaldir(-1, vim.api.nvim_tabpage_get_number(nr))
			if has_tcd == 1 then
				local tcd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(nr))
				table.insert(lines, "tcd " .. tcd)
			end

			local project_dir = vim.t.project_dir

			if project_dir ~= nil then
				table.insert(lines, 'let t:project_dir = "' .. project_dir .. '"')
			end

			local layout_name = vim.t.layout_name
			if layout_name ~= nil then
				table.insert(lines, 'let t:layout_name = "' .. layout_name .. '"')
			end
		end

		table.insert(lines, "tabnext " .. current_nr)
		table.insert(lines, "redrawtabline")

		vim.fn.writefile(lines, extra_session_file)
	end,
})

M.restore_session = function()
	if vim.fn.filereadable(session_file) == 1 then
		vim.cmd.source(session_file)
	else
		vim.notify("No session file found", vim.log.levels.ERROR)
	end
end

M.plugins = {}

return M
