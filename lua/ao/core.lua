local m = {}

function m.netrw_current_file()
	local pathname = vim.fn.expand("%:p:h")
	vim.fn.execute("edit " .. pathname)
end

function m.netrw_current_project()
	local pathname = vim.fn.ProjectRootGuess()
	vim.fn.execute("edit " .. pathname)
end

-----------------------------------------------------------
-- Function equivalent to basename in POSIX systems.
-- @param str the path string.
-----------------------------------------------------------
function m.basename(str)
	return string.gsub(str, "(.*/)(.*)", "%2")
end

-----------------------------------------------------------
-- Contatenates given paths with correct separator.
-- @param: var args of string paths to joon.
-----------------------------------------------------------
function m.join_paths(...)
	local result = table.concat({ ... }, "/")
	return result
end

local _base_lua_path = m.join_paths(vim.fn.stdpath("config"), "lua")

-----------------------------------------------------------
-- Loads all modules from the given package.
-- @param package: name of the package in lua folder.
-----------------------------------------------------------
function m.glob_require(package)
	local glob_path = m.join_paths(_base_lua_path, package, "*.lua")

	for _, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
		-- convert absolute filename to relative
		-- ~/.config/nvim/lua/<package>/<module>.lua => <package>/foo
		local relfilename = path:gsub(_base_lua_path, ""):gsub(".lua", "")
		local basename = m.basename(relfilename)
		-- skip `init` and files starting with underscore.
		if basename ~= "init" and basename ~= "commentary" and basename:sub(1, 1) ~= "_" then
			require(relfilename)
		end
	end
end

m.table_concat = function(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

m.ensure_package_manager = function()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end

	vim.opt.rtp:prepend(lazypath)
end

return m
