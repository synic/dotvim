local M = {}

function M.copy_normalized_block()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" then
		return
	end

	vim.cmd([[silent normal! "xy]])
	local text = vim.fn.getreg("x")
	local lines = vim.split(text, "\n", { plain = true })

	local converted = {}
	for _, line in ipairs(lines) do
		local l = line:gsub("\t", "  ")
		table.insert(converted, l)
	end

	local min_indent = math.huge
	for _, line in ipairs(converted) do
		if line:match("[^%s]") then
			local indent = #(line:match("^%s*"))
			min_indent = math.min(min_indent, indent)
		end
	end
	min_indent = min_indent == math.huge and 0 or min_indent

	local result = {}
	for _, line in ipairs(converted) do
		if line:match("^%s*$") then
			table.insert(result, "")
		else
			local processed = line:sub(min_indent + 1)
			processed = processed:gsub("^%s+", function(spaces)
				return string.rep("  ", math.floor(#spaces / 2))
			end)
			table.insert(result, processed)
		end
	end

	local normalized = table.concat(result, "\n")
	vim.fn.setreg("+", normalized)
	vim.notify("Copied normalized text to clipboard")
end

return M
