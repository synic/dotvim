local config = require("ao.config")
local utils = require("ao.utils")

local M = {}
local root_cache = {}
local chdir_group = vim.api.nvim_create_augroup("ProjectAutoChdir", { clear = true })
local frecency_data = {}
local frecency_file = vim.fn.stdpath("data") .. "/project_frecency.json"
local pick_project
local find_project_files

local function load_frecency()
	local file = io.open(frecency_file, "r")
	if file then
		---@diagnostic disable-next-line: undefined-field
		local content = file:read("*all")
		---@diagnostic disable-next-line: undefined-field
		file:close()
		local ok, data = pcall(vim.json.decode, content)
		if ok then
			frecency_data = data
		end
	end
end

local function save_frecency()
	vim.schedule(function()
		local file = io.open(frecency_file, "w")
		if file then
			---@diagnostic disable-next-line: undefined-field
			file:write(vim.json.encode(frecency_data))
			---@diagnostic disable-next-line: undefined-field
			file:close()
		end
	end)
end

local function update_frecency(dir)
	frecency_data[dir] = frecency_data[dir] or { count = 0, last_opened = 0 }
	frecency_data[dir].count = frecency_data[dir].count + 1
	frecency_data[dir].last_opened = os.time()
	save_frecency()
end

local function get_frecency_score(dir)
	if not frecency_data[dir] then
		return 0
	end
	local time_factor = 1.0 / (1.0 + (os.time() - frecency_data[dir].last_opened) / (24 * 60 * 60))
	return frecency_data[dir].count * time_factor
end

function string.starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

-- would rather not use this function and instead just use `:tcd` per tab, however, there are various plugins that
-- have issue with the file not being in the same location as the cwd (stylua, for example, has trouble saving if the
-- cwd is some other directory.
local function setup_autochdir()
	local chdir_aucmds = { "BufNewFile", "BufRead", "BufFilePost", "BufEnter", "VimEnter" }
	local skip_filetype_patterns = { "^qf$", "^Neogit" }

	vim.api.nvim_create_autocmd(chdir_aucmds, {
		group = chdir_group,
		callback = function(opts)
			for _, pattern in ipairs(skip_filetype_patterns) do
				if vim.bo[opts.buf].filetype:find(pattern) ~= nil then
					return
				end
			end
			local root = M.find_buffer_root(opts.buf)
			if root and root ~= "" then
				vim.cmd.cd(root)
			end
		end,
	})
end

local function goto_project_directory()
	local dir = config.options.projects.directory or "."
	vim.cmd.edit(dir)
end

local function setup_project_hotkeys()
	local keys = {}
	for key, dir in pairs(config.options.projects.bookmarks) do
		local name = vim.fn.fnamemodify(dir, ":t")
		keys[#keys + 1] = {
			"<leader>p" .. key,
			function()
				vim.cmd.tabnew()
				M.open(dir)
			end,
			desc = "Open project " .. name,
		}
	end

	utils.map_keys(keys)
end

local function git_files()
	local root = M.find_buffer_root()
	if root and root ~= "" then
		require("fzf-lua")["git_files"]({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		pick_project()
	end
end

local function dirpicker_pick_project(cb)
	local cwd = config.options.projects.directory.path or "."
	local projects = M.list({ cwd = cwd })
	local width = 0
	local height = #projects + 2

	if height > 25 then
		height = 25
	end

	local max_name_length = 0
	for _, entry in ipairs(projects) do
		max_name_length = math.max(max_name_length, #entry.name)
		local total_length = #entry.name + #entry.path + 20
		if total_length > width then
			width = total_length
		end
	end

	if width > 150 then
		width = 150
	end

	local padding = max_name_length + 15
	local entries = {}

	for _, entry in ipairs(projects) do
		local display = string.format("%-" .. padding .. "s\x1b[90m\x1E%s\x1E\x1b[0m", entry.name, entry.path)
		entries[#entries + 1] = display
	end

	require("fzf-lua").fzf_exec(entries, {
		winopts = {
			height = height,
			width = width,
			row = math.floor((vim.o.lines - height) / 2 / 1.2),
			col = math.floor((vim.o.columns - width) / 2),
		},
		actions = {
			["default"] = function(selected, _)
				local path = selected[1]:match("\x1E(.*)\x1E")
				cb(path)
			end,
			["ctrl-s"] = function(selected, _)
				local path = selected[1]:match("\x1E(.*)\x1E")
				vim.cmd.split(path)
				cb(path)
			end,
			["ctrl-v"] = function(selected, _)
				local path = selected[1]:match("\x1E(.*)\x1E")
				vim.cmd.vsplit(path)
				cb(path)
			end,
		},
	})
end

function pick_project()
	dirpicker_pick_project(M.open)
end

local function switch_project()
	---@diagnostic disable-next-line: inject-field
	vim.t.project_dir = nil
	---@diagnostic disable-next-line: inject-field
	vim.t.layout_name = nil
	pick_project()
end

local function new_tab_with_project()
	dirpicker_pick_project(function(dir)
		vim.cmd.tabnew()
		M.open(dir)
	end)
end

local function goto_project()
	vim.cmd.Oil(vim.fn.getcwd(-1, 0))
end

local function set_project()
	local root = M.find_buffer_root()
	if root and root ~= "" then
		M.set(root)
	end
end

local function grep_project()
	require("fzf-lua")["live_grep"]({ cwd = (M.find_buffer_root() or ".") })
end

function find_project_files()
	local root = M.find_buffer_root()
	if root and root ~= "" then
		if not vim.t.project_dir then
			M.set(root)
		end
		require("fzf-lua")["files"]({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		pick_project()
	end
end

function M.list(opts)
	local path = require("plenary.path")
	local items, projects = {}, {}
	local dirs = vim.split(vim.fn.glob(opts.cwd .. "/*"), "\n", { trimempty = true })

	for _, entry in ipairs(config.options.projects.entries) do
		items[#items + 1] = entry
	end

	for _, dir in ipairs(dirs) do
		---@diagnostic disable-next-line: need-check-nil, param-type-mismatch
		if string.sub(dir, 1, 1) and path.new(dir):is_dir() then
			if not string.starts_with(dir, ".") then
				if not vim.tbl_contains(config.options.projects.directory.skip, vim.fn.fnamemodify(dir, ":t")) then
					for _, check_file in ipairs(config.options.projects.root_names) do
						if vim.fn.filereadable(dir .. "/" .. check_file) then
							items[#items + 1] = { path = dir, name = vim.fn.fnamemodify(dir, ":t") }
							break
						end
					end
				end
			end
		end
	end

	table.sort(items, function(p1, p2)
		local path1 = type(p1) == "table" and p1.path or p1
		local path2 = type(p2) == "table" and p2.path or p2
		local score1 = get_frecency_score(path1)
		local score2 = get_frecency_score(path2)
		if score1 == score2 then
			return string.lower(path1) > string.lower(path2)
		end
		return score1 > score2
	end)

	for _, item in ipairs(items) do
		projects[#projects + 1] = item
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

	root = vim.fs.root(path, config.options.projects.root_names)
	root_cache[path] = root or -1

	return root
end

function M.find_buffer_root(buf)
	buf = buf or 0
	local cwd = vim.bo[buf].filetype == "oil" and require("oil").get_current_dir(buf) or utils.get_buffer_cwd(buf)
	return M.find_path_root(cwd)
end

function M.get_dir(tabnr)
	local path = M.find_path_root(vim.fn.getcwd(-1, tabnr or 0))
	return path
end

function M.get_name(tabnr)
	local name = vim.fn.gettabvar(tabnr or 0, "layout_name")
	if name and name ~= "" then
		return name
	end
	return nil
end

function M.set(dir)
	print("Project: opening", dir)
	---@diagnostic disable-next-line: inject-field
	vim.t.project_dir = dir
	---@diagnostic disable-next-line: inject-field
	vim.t.layout_name = vim.fn.fnamemodify(dir, ":t")
	vim.cmd.redrawtabline()
end

function M.open(dir)
	if not vim.t.project_dir then
		M.set(dir)
	end

	update_frecency(dir)
	require("fzf-lua")["files"]({ cwd = dir })
end

M.plugin_specs = {}

utils.map_keys({
	{ "<leader>p-", goto_project_directory, desc = "Go to project directory" },
	{ "<leader>lt", new_tab_with_project, desc = "New layout with project" },
	{ "<leader>*", "<cmd>FzfLua grep_cword<cr>", desc = "Search project for term", modes = { "n", "v" } },
	{ "<leader>sp", grep_project, desc = "Search project for text" },
	{ "<leader>p/", grep_project, desc = "Search project for text" },
	{ "<leader>pf", find_project_files, desc = "Find project file" },
	{ "<leader>pg", git_files, desc = "Find git files" },
	{ "<leader>pp", pick_project, desc = "Pick project" },
	{ "<leader>pP", switch_project, desc = "Switch project" },
	{ "<leader>ph", goto_project, desc = "Go to project home" },
	{ "<leader>pS", set_project, desc = "Set project home" },
})

load_frecency()
setup_autochdir()
setup_project_hotkeys()

return M
