local module = {}

function module.basename(str)
	return string.gsub(str, "(.*/)(.*)", "%2")
end

function module.join_paths(...)
	local result = table.concat({ ... }, "/")
	return result
end

module.table_concat = function(table1, table2)
	for i = 1, #table2 do
		table1[#table1 + 1] = table2[i]
	end
	return table1
end

return module
