---@alias KeymapOpts { buffer?: boolean, desc?: string, expr?: boolean, modes?: string[], silent?: boolean, test?: boolean }
---@alias Keymap { [1]: string, [2]: string|function, desc?: string, buffer?: boolean, expr?: boolean, mode?: string[], silent?: boolean, test?: boolean|number }

local M = {}

---@param keymap Keymap[]
---@return nil
function M.map(keymap)
	for _, key_data in ipairs(keymap) do
		local mode = key_data.mode or { "n" }
		local should_apply = true

		if key_data.test ~= nil then
			should_apply = key_data.test ~= 0 and key_data.test ~= nil
			key_data.test = nil
		end

		key_data.mode = nil

		if should_apply then
			local left = key_data[1]
			local right = key_data[2]

			key_data[1] = nil
			key_data[2] = nil

			for _, m in ipairs(mode) do
				vim.keymap.set(m, left, right, key_data)
			end
		end
	end
end

return M
