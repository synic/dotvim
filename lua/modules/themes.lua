local setup_colors_group = vim.api.nvim_create_augroup("SetupColors", { clear = true })

---@type PluginModule
local M = {}

---@param pattern string Pattern to match colorscheme name against
---@param cb ColorSchemeCallback Callback to run when colorscheme loads
---@return nil
function M.on_colorscheme_load(pattern, cb)
	cb()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		group = setup_colors_group,
		callback = function(cs)
			if cs.match:find(pattern) ~= nil then
				cb()
			end
		end,
	})
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = setup_colors_group,
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "SnacksPicker", { ctermbg = 0, blend = vim.g.neovide and 40 or 7 })
		vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
		vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
		vim.api.nvim_set_hl(0, "SignatureMarkText", { link = "DiagnosticSignInfo" })
	end,
})

function M.colorscheme_picker()
	require("snacks").picker.colorschemes()
end

return M
