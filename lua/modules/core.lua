local config = require("modules.config")
local local_config_path = vim.fn.stdpath("config") .. "/local_config.lua"

local M = {}

local function load_lazy_plugins()
	local path = vim.fn.stdpath("config") .. "/lazy"
	local lazyplugins = vim.split(vim.fn.glob(vim.fn.resolve(path .. "/*.lua")), "\n", { trimempty = true })

	for _, filename in ipairs(lazyplugins) do
		dofile(filename)
	end
end

---@return nil
function M.setup()
	require("modules.options").setup()
	require("modules.session").setup()

	if vim.fn.filereadable(local_config_path) == 1 then
		local local_config_module = dofile(local_config_path)
		config.options = vim.tbl_deep_extend("force", config.options, local_config_module)
	end

	require("modules.lsp").setup()

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if config.options.appearance.font then
				vim.o.guifont = config.options.appearance.font
			end

			if config.options.appearance.theme then
				vim.cmd.colorscheme(config.options.appearance.theme)
			end

			load_lazy_plugins()

			require("modules.keymap").setup_basic_keymap()
		end,
	})
end

return M
