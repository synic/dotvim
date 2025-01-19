local uv = vim.uv or vim.loop

local M = {}

function M.get_buffer_cwd(bufnr, winnr)
	local path = vim.api.nvim_buf_get_name(bufnr or 0)

	if not path or path == "" then
		-- only check cwd if bufnr wasn't passed
		if not bufnr then
			path = vim.fn.getcwd(winnr or 0)
		end
	elseif path:find("^oil:") then
		_, path = M.remove_oil(path)
	else
		path = vim.fs.dirname(path)
	end

	return path
end

function M.normalize_path(path, cwd)
	return require("plenary.path"):new(path):normalize(cwd or uv.cwd())
end

---@param str string
---@return string
function M.basename(str)
	---@diagnostic disable-next-line: redundant-return-value
	return string.gsub(str, "(.*/)(.*)", "%2")
end

---@param ... string
---@return string
function M.join(...)
	local result = table.concat({ ... }, "/")
	return result
end

function M.remove_oil(path)
	if path == "oil:" then
		return true, "/"
	elseif path:find("^oil://") then
		return true, string.sub(path, 7)
	end
	return false, path
end

return M
