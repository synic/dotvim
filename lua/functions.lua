local M = {}

function M.netrw_current_file()
	local pathname = vim.fn.expand("%:p:h")
	vim.fn.execute("edit " .. pathname)
end

function M.netrw_current_project()
	local pathname = vim.fn.ProjectRootGuess()
	vim.fn.execute("edit " .. pathname)
end

-----------------------------------------------------------
-- Function equivalent to basename in POSIX systems.
-- @param str the path string.
-----------------------------------------------------------
function M.basename(str)
	return string.gsub(str, "(.*/)(.*)", "%2")
end

-----------------------------------------------------------
-- Contatenates given paths with correct separator.
-- @param: var args of string paths to joon.
-----------------------------------------------------------
function M.join_paths(...)
	local result = table.concat({ ... }, "/")
	return result
end

local _base_lua_path = M.join_paths(vim.fn.stdpath("config"), "lua")

-----------------------------------------------------------
-- Loads all modules from the given package.
-- @param package: name of the package in lua folder.
-----------------------------------------------------------
function M.glob_require(package)
	glob_path = M.join_paths(_base_lua_path, package, "*.lua")

	for i, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
		-- convert absolute filename to relative
		-- ~/.config/nvim/lua/<package>/<module>.lua => <package>/foo
		relfilename = path:gsub(_base_lua_path, ""):gsub(".lua", "")
		basename = M.basename(relfilename)
		-- skip `init` and files starting with underscore.
		if basename ~= "init" and basename:sub(1, 1) ~= "_" then
			require(relfilename)
		end
	end
end

return M
