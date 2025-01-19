local M = {}

---@param table1 table
---@param table2 table
---@return table
function M.concat(table1, table2)
	for i = 1, #table2 do
		table1[#table1 + 1] = table2[i]
	end
	return table1
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

return M
