local config = require("ao.config")
local utils = require("ao.utils")

local M = {}
local root_cache = {}
local uv = vim.uv or vim.loop

local function telescope_search_project_cursor_term()
	local builtin = require("telescope.builtin")
	local current_word = vim.fn.expand("<cword>")
	local root = M.find_buffer_root()

	builtin.grep_string({ cwd = (root or "."), search = current_word })
end

local function telescope_git_files()
	local builtin = require("telescope.builtin")

	local root = M.find_buffer_root()
	if root and root ~= "" then
		builtin.git_files({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		M.telescope_pick_project()
	end
end

local function dirpicker_pick_project(cb)
	require("telescope").extensions.dirpicker.dirpicker({
		cwd = config.options.projects.directory or ".",
		layout_config = { width = 0.45, height = 0.4, preview_width = 0.5 },
		prompt_title = "Projects",
		cmd = M.find_projects,
		on_select = cb,
	})
end

local function telescope_pick_project()
	dirpicker_pick_project(M.open)
end

local function telescope_switch_project()
	vim.t.project_dir = false
	telescope_pick_project()
end

local function telescope_new_tab_with_project()
	dirpicker_pick_project(function(dir)
		vim.cmd.tabnew()
		M.open(dir)
	end)
end

local function telescope_goto_project()
	vim.cmd.Oil(vim.fn.getcwd(-1, 0))
end

local function telescope_set_project()
	local root = M.find_buffer_root()
	if root and root ~= "" then
		M.set(root)
	end
end

local function telescope_search_project()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = (M.find_buffer_root() or ".") })
end

local function telescope_find_project_files()
	local builtin = require("telescope.builtin")

	local root = M.find_buffer_root()
	if root and root ~= "" then
		builtin.find_files({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		telescope_pick_project()
	end
end

function M.find_projects(opts)
	local path = require("plenary.path")
	local items, projects = {}, {}
	local files = vim.split(vim.fn.glob(opts.cwd .. "/*"), "\n", { trimempty = true })

	for _, file in ipairs(files) do
		if string.sub(file, 1, 1) and path.new(file):is_dir() then
			local fd = uv.fs_open(file .. "/.git/index", "r", 438)

			if fd ~= nil then
				local stat = uv.fs_fstat(fd)
				if stat ~= nil then
					table.insert(items, { path = file, mtime = stat.mtime })
				end
			else
				table.insert(items, { path = file, mtime = { sec = 0 } })
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
	local path = vim.fn.gettabvar(tabnr or 0, "project_dir")
	return (path and path ~= "") and vim.fs.basename(path) or nil
end

function M.set(dir)
	print("Project: opening", dir)
	vim.t.project_dir = dir
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
				vim.cmd.cd(root)
			end
		end,
	})
end

M.setup_autochdir()

function M.open(dir)
	if not vim.t.project_dir then
		M.set(dir)
	end

	require("telescope.builtin").find_files({ cwd = dir })
end

M.plugin_specs = {
	{
		"synic/telescope-dirpicker.nvim",
		dependencies = { "telescope.nvim" },
		keys = {
			{ "<leader>lt", telescope_new_tab_with_project, desc = "New layout with project" },
			{ "<leader>*", telescope_search_project_cursor_term, desc = "Search project for term", mode = { "n", "v" } },
			{ "<leader>sp", telescope_search_project, desc = "Search project for text" },
			{ "<leader>p/", telescope_search_project, desc = "Search project for text" },
			{ "<leader>pf", telescope_find_project_files, desc = "Find project file" },
			{ "<leader>pg", telescope_git_files, desc = "Find git files" },
			{ "<leader>pp", telescope_pick_project, desc = "Pick project" },
			{ "<leader>pP", telescope_switch_project, desc = "Switch project" },
			{ "<leader>ph", telescope_goto_project, desc = "Go to project home" },
			{ "<leader>pS", telescope_set_project, desc = "Set project home" },
		},
	},
}

return M
