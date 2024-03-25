local config = require("ao.config")
local utils = require("ao.utils")

local M = { plugin_specs = {} }
local root_cache = {}

function M.find_projects(opts)
	local path = require("plenary.path")
	local items, projects = {}, {}
	local files = vim.split(vim.fn.glob(opts.cwd .. "/*"), "\n", { trimempty = true })
	local uv = vim.loop

	for _, file in ipairs(files) do
		if string.sub(file, 1, 1) and path.new(file):is_dir() then
			local fd = uv.fs_open(file .. "", "r", 438)

			if fd ~= nil then
				local stat = uv.fs_fstat(fd)
				if stat ~= nil then
					table.insert(items, { path = file, mtime = stat.mtime })
				end
			else
				table.insert(items, { path = file, mtime = 0 })
			end
		end
	end

	table.sort(items, function(p1, p2)
		return p1.mtime.sec > p2.mtime.sec
	end)

	for _, item in ipairs(items) do
		table.insert(projects, item.path)
	end

	return projects
end

function M.find_path_root(path)
	if not path or path == "" then
		return nil
	end
	local root = root_cache[path]

	if root ~= nil then
		if root == -1 then
			return nil
		end
		return root
	end

	root = vim.fs.find(config.options.projects.root_names, { path = path, upward = true })[1]

	if root ~= nil then
		root = vim.fs.dirname(root)
	end

	root_cache[path] = root or -1
	return root
end

function M.find_buffer_root(bufnr)
	return M.find_path_root(utils.get_buffer_cwd(bufnr))
end

function M.get_dir(tabnr)
	local path = M.find_path_root(vim.fn.getcwd(-1, tabnr or 0))
	return path
end

function M.get_name(tabnr)
	local path = M.get_dir(tabnr)
	return path and vim.fs.basename(path) or nil
end

function M.set(dir)
	vim.t.projectset = true
	vim.cmd.tcd(dir)
	vim.cmd.redrawtabline()
end

-- would rather not use this function and instead just use `:tcd` per tab (which I'm doing anyway), however,
-- there are various plugins that have issue with the file not being in the same location as the cwd (stylua, for
-- example, has trouble saving if the cwd is some other directory.
function M.setup_autochdir()
	local chdir_aucmds = { "BufNewFile", "BufRead", "BufFilePost", "BufEnter", "VimEnter" }

	vim.api.nvim_create_autocmd(chdir_aucmds, {
		callback = function(opts)
			local root = M.find_buffer_root(opts.buf)
			if root and root ~= "" then
				vim.cmd.lcd(root)
			end
		end,
	})
end

-- M.setup_autochdir()

function M.open(dir)
	dir = vim.fn.resolve(vim.fn.expand(dir))
	print("Project: opening", dir)
	if not vim.t.projectset then
		M.set(dir)
	end

	require("telescope.builtin").find_files({ cwd = dir })
end

return M
