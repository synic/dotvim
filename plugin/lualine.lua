vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })

---@param trunc_width? integer
---@param trunc_len? integer
---@param hide_width? integer
---@param no_ellipsis? boolean
---@return fun(str: string): string
local function lualine_trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
	return function(str)
		local win_width = vim.fn.winwidth(0)
		if hide_width and win_width < hide_width then
			return ""
		elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
			return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
		end
		return str
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local proj = require("modules.project")
		local lualine_utils = require("lualine.utils.utils")

		local function repo_name(_, is_focused)
			if not is_focused then
				return ""
			end

			local path = proj.find_buffer_root()
			return lualine_utils.stl_escape(vim.fs.basename(path or ""))
		end

		return {
			options = {
				component_separators = "|",
				-- section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_b = {
					{ repo_name, icon = "" },
					{ "diff" },
					{ "diagnostics" },
				},
				lualine_c = {
					{ "filename", file_status = true, path = 1 },
				},
				lualine_x = {
					{ "encoding", fmt = lualine_trunc(0, 0, 120) },
					{ "fileformat", fmt = lualine_trunc(0, 0, 120) },
					{ "filetype", fmt = lualine_trunc(0, 0, 120) },
				},
				lualine_y = {
					{ "progress", fmt = lualine_trunc(0, 0, 100) },
				},
			},
			inactive_sections = {
				lualine_c = {
					{ "filename", file_status = true, path = 1 },
				},
			},
		}
	end,
})
