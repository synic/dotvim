local M = {}

---@param tbl table
---@param ... table
---@return table
function M.concat(tbl, ...)
	for _, source in ipairs({ ... }) do
		for i = 1, #source do
			tbl[#tbl + 1] = source[i]
		end
	end
	return tbl
end

---@param tbl table
---@param value any
---@return boolean
function M.contains(tbl, value)
	for i = 1, #tbl do
		if tbl[i] == value then
			return true
		end
	end
	return false
end

---@param ... table
---@return table
function M.unique(...)
	local seen = {}
	local result = {}
	for _, tbl in ipairs({ ... }) do
		for _, v in ipairs(tbl) do
			if not seen[v] then
				seen[v] = true
				table.insert(result, v)
			end
		end
	end
	return result
end

return M
