local M = {}

function M.set_tab_var(tabnr, key, value)
	local handle = vim.api.nvim_list_tabpages()[tabnr or vim.fn.tabpagenr()]
	if handle == nil then
		return
	end
	vim.api.nvim_tabpage_set_var(handle, key, value)
end

function M.set_buf_var(bufnr, key, value)
	local handle = vim.api.nvim_list_bufs()[bufnr or vim.fn.bufnr()]
	if handle == nil then
		return
	end
	vim.api.nvim_buf_set_var(handle, key, value)
end

return M
