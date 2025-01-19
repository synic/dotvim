local init_group = vim.api.nvim_create_augroup("UtilsOnLoad", { clear = true })

local M = {}

function M.on_load(name, callback)
	local has_lazy, config = pcall(require, "lazy.core.config")

	-- if it's already loaded, then just run the callback
	if has_lazy then
		if config.plugins[name]._.loaded ~= nil then
			callback(name)
			return
		end
	end

	vim.api.nvim_create_autocmd("User", {
		group = init_group,
		pattern = "LazyLoad",
		callback = function(event)
			if event.data == name then
				callback(name)
				return true
			end
		end,
	})
end

return M
