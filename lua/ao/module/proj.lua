local config = require("ao.config")
local fs = require("ao.fs")
local keymap = require("ao.keymap")

---@class Project
---@field name string
---@field path string
---@field text? string

---@class ProjectFrecencyData
---@field count number
---@field last_opened number

---@class ProjectModule
---@field plugins LazySpec[]
---@field list fun(opts: { cwd: string }): Project[]
---@field find_path_root fun(path: string|nil): string|nil
---@field find_buffer_root fun(buf?: number): string|nil
---@field get_dir fun(tabnr?: number): string|nil
---@field get_name fun(tabnr?: number): string|nil
---@field set fun(dir: string): nil
---@field open fun(dir: string): nil

local M = {}

---@type table<string, string|number|nil>
local root_cache = {}

local chdir_group = vim.api.nvim_create_augroup("ProjectAutoChdir", { clear = true })

---@type table<string, ProjectFrecencyData>
local frecency_data = {}
local frecency_file = vim.fn.stdpath("data") .. "/project_frecency.json"
local pick_project
local find_project_files

---@return nil
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

---@return nil
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

---@param dir string
---@return nil
local function update_frecency(dir)
	frecency_data[dir] = frecency_data[dir] or { count = 0, last_opened = 0 }
	frecency_data[dir].count = frecency_data[dir].count + 1
	frecency_data[dir].last_opened = os.time()
	save_frecency()
end

---@param dir string
---@return number
local function get_frecency_score(dir)
	if not frecency_data[dir] then
		return 0
	end
	local time_factor = 1.0 / (1.0 + (os.time() - frecency_data[dir].last_opened) / (24 * 60 * 60))
	return frecency_data[dir].count * time_factor
end

---@param str string
---@param start string
---@return boolean
function string.starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

-- would rather not use this function and instead just use `:tcd` per tab, however, there are various plugins that
-- have issue with the file not being in the same location as the cwd (stylua, for example, has trouble saving if the
-- cwd is some other directory.
---@return nil
local function setup_autochdir()
	if true then
		return
	end
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
				vim.cmd.lcd(root)
			end
		end,
	})
end

---@return nil
local function goto_project_directory()
	local dir = config.options.projects.directory or "."
	vim.cmd.edit(dir)
end

---@return nil
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

	keymap.add(keys)
end

---@return nil
local function search_project_cursor_term()
	local picker = require("snacks").picker
	local current_word = vim.fn.expand("<cword>")
	local root = M.find_buffer_root()

	---@diagnostic disable-next-line: missing-fields
	picker.grep({ cwd = (root or "."), search = current_word })
end

---@return nil
local function git_files()
	local picker = require("snacks").picker

	local root = M.find_buffer_root()
	if root and root ~= "" then
		---@diagnostic disable-next-line: missing-fields
		picker.git_files({ cwd = (root or ".") })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		pick_project()
	end
end

---@param cb fun(path: string): nil
---@return nil
local function dirpicker_pick_project(cb)
	local snacks = require("snacks")
	local layouts = require("snacks.picker.config.layouts")

	local cwd = config.options.projects.directory.path or "."
	local projects = M.list({ cwd = cwd })

	local width = 0
	local height = math.min(#projects + 5, 25)

	local max_name_length = 0
	for _, entry in ipairs(projects) do
		entry.text = entry.name .. entry.path
		max_name_length = math.max(max_name_length, #entry.name)
		local total_length = #entry.text + 20
		if total_length > width then
			width = total_length
		end
	end

	width = math.min(width, 150)
	local padding = max_name_length + 15

	snacks.picker.pick({
		items = projects,
		format = function(item, _)
			local ret = {}
			ret[#ret + 1] = { item.name, "SnacksFileLabel" }
			ret[#ret + 1] = { string.rep(" ", padding - #item.name), virtual = true }
			ret[#ret + 1] = { item.path, "SnacksPickerComment" }
			return ret
		end,
		layout = vim.tbl_deep_extend("force", layouts.telescope, {
			layout = {
				width = width,
				height = height,
				min_width = width,
				min_height = height,
				{
					box = "vertical",
					{ win = "list", title = " Projects ", title_pos = "center", border = "rounded" },
					{ win = "input", height = 1, border = "rounded", title = "{source} {live}", title_pos = "center" },
				},
			},
			preview = false,
		}),
		confirm = function(picker, entry)
			picker:close()
			if entry then
				cb(entry.path)
			end
		end,
		actions = {
			open_in_vsplit = function(picker, entry)
				picker:close()
				vim.cmd.vsplit(entry.path)
				M.open(entry.path)
			end,
			open_in_split = function(picker, entry)
				picker:close()
				vim.cmd.split(entry.path)
				M.open(entry.path)
			end,
			browse = function(picker, entry)
				picker:close()
				vim.cmd("edit! " .. entry.path)
				M.set(entry.path)
			end,
			browse_in_vsplit = function(picker, entry)
				picker:close()
				vim.cmd("vsplit! " .. entry.path)
				M.set(entry.path)
			end,
			browse_in_split = function(picker, entry)
				picker:close()
				vim.cmd("split! " .. entry.path)
				M.set(entry.path)
			end,
			set_layout = function(picker, entry)
				picker:close()
				M.set(entry.value)
				vim.notify("Project: set current layout project to " .. entry.name)
			end,
		},
		win = {
			input = {
				keys = {
					["//"] = { "open_in_vsplit", desc = "Open in vertical split", mode = { "i" } },
					["--"] = { "open_in_split", desc = "Open in horiontal split", mode = { "i" } },
					["<c-e>"] = { "browse", desc = "Open in file browser", mode = { "i" } },
					["<c-v>"] = { "browse_in_vsplit", desc = "File browser in split", mode = { "i" } },
					["<c-s>"] = { "browse_in_split", desc = "File browser in split", mode = { "i" } },
					["<c-p>"] = { "set_layout", desc = "Set layout project", mode = { "i" } },
				},
			},
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

local function search_project()
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.grep({ cwd = (M.find_buffer_root() or ".") })
end

function find_project_files()
	local snacks = require("snacks")

	local root = M.find_buffer_root()
	if root and root ~= "" then
		if not vim.t.project_dir then
			M.set(root)
		end
		---@diagnostic disable-next-line: missing-fields
		snacks.picker.files({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		pick_project()
	end
end

---@param opts { cwd: string }
---@return Project[]
function M.list(opts)
	local path = require("plenary.path")
	local items, projects = {}, {}
	local dirs = vim.split(vim.fn.glob(opts.cwd .. "/*"), "\n", { trimempty = true })

	-- Add configured entries to items list instead of projects directly
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
							items[#items + 1] = { name = vim.fn.fnamemodify(dir, ":t"), path = dir }
							break
						end
					end
				end
			end
		end
	end

	table.sort(items, function(p1, p2)
		local score1 = get_frecency_score(p1.path)
		local score2 = get_frecency_score(p2.path)
		if score1 == score2 then
			return string.lower(p1.path) > string.lower(p2.path)
		end
		return score1 > score2
	end)

	for _, item in ipairs(items) do
		projects[#projects + 1] = item
	end

	return projects
end

---@param path string|nil
---@return string|nil
function M.find_path_root(path)
	if not path or path == "" then
		return nil
	end
	local root = root_cache[path]

	if root ~= nil then
		if root == -1 then
			return nil
		end
		---@diagnostic disable-next-line: return-type-mismatch
		return root
	end

	root = vim.fs.root(path, config.options.projects.root_names)
	root_cache[path] = root or -1

	return root
end

---@param buf number|nil
---@return string|nil
function M.find_buffer_root(buf)
	buf = buf or 0
	local cwd = vim.bo[buf].filetype == "oil" and require("oil").get_current_dir(buf) or fs.get_buffer_cwd(buf)
	return M.find_path_root(cwd)
end

---@param tabnr number|nil
---@return string|nil
function M.get_dir(tabnr)
	return M.find_path_root(vim.fn.getcwd(-1, tabnr or 0))
end

---@param tabnr number|nil
---@return string|nil
function M.get_name(tabnr)
	local name = vim.fn.gettabvar(tabnr or 0, "layout_name")
	if name and name ~= "" then
		return name
	end
	return nil
end

---@param dir string
---@return nil
function M.set(dir)
	print("Project: opening", dir)
	---@diagnostic disable-next-line: inject-field
	vim.t.project_dir = dir
	---@diagnostic disable-next-line: inject-field
	vim.t.layout_name = vim.fn.fnamemodify(dir, ":t")
	vim.cmd.redrawtabline()
	vim.cmd.tcd(dir)
end

---@param dir string
---@return nil
function M.open(dir)
	if not vim.t.project_dir then
		M.set(dir)
	end

	update_frecency(dir)
	---@diagnostic disable-next-line: missing-fields
	require("snacks").picker.files({ cwd = dir })
end

keymap.add({
	{ "<leader>p-", goto_project_directory, desc = "Go to project directory" },
	{ "<leader>lt", new_tab_with_project, desc = "New layout with project" },
	{ "<leader>*", search_project_cursor_term, desc = "Search project for term", mode = { "n", "v" } },
	{ "<leader>sp", search_project, desc = "Search project for text" },
	{ "<leader>p/", search_project, desc = "Search project for text" },
	{ "<leader>pf", find_project_files, desc = "Find project file" },
	{ "<leader>pg", git_files, desc = "Find git files" },
	{ "<leader>pp", pick_project, desc = "Pick project" },
	{ "<leader>pP", switch_project, desc = "Switch project" },
	{ "<leader>ph", goto_project, desc = "Go to project home" },
	{ "<leader>pS", set_project, desc = "Set project home" },
})

M.plugins = {}

load_frecency()
setup_autochdir()
setup_project_hotkeys()

return M
