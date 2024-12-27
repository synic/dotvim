local config = require("ao.config")
local utils = require("ao.utils")

local M = {}
local root_cache = {}
local chdir_group = vim.api.nvim_create_augroup("ProjectAutoChdir", { clear = true })
local frecency_data = {}
local frecency_file = vim.fn.stdpath("data") .. "/project_frecency.json"

local function load_frecency()
	local file = io.open(frecency_file, "r")
	if file then
		local content = file:read("*all")
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
			file:write(vim.json.encode(frecency_data))
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
	local cwd = config.options.projects.directory.path or "."
	local width = 0.37
	if vim.o.columns < 130 then
		width = 0.50
	end

	local projects = M.list({ cwd = cwd })
	local height = #projects + 5 -- number of projects, plus padding and borders, plus input box

	if height > 25 then
		height = 25
	end

	require("telescope").extensions.dirpicker.dirpicker({
		cwd = cwd,
		enable_preview = false,
		layout_config = { width = width, height = height },
		prompt_title = "Projects",
		cmd = function(_)
			return projects
		end,
		on_select = cb,
	})
end

local function telescope_pick_project()
	dirpicker_pick_project(M.open)
end

local function telescope_switch_project()
	vim.t.project_dir = nil
	vim.t.layout_name = nil
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
		if not vim.t.project_dir then
			M.set(root)
		end
		builtin.find_files({ cwd = root })
	else
		vim.notify("Project: no project selected", vim.log.levels.INFO)
		telescope_pick_project()
	end
end

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
							items[#items + 1] = dir
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

	root = vim.fs.root(0, config.options.projects.root_names)

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
	local name = vim.fn.gettabvar(tabnr or 0, "layout_name")
	if name and name ~= "" then
		return name
	end
	return nil
end

function M.set(dir)
	print("Project: opening", dir)
	vim.t.project_dir = dir
	vim.t.layout_name = vim.fn.fnamemodify(dir, ":t")
	vim.cmd.redrawtabline()
end

function M.open(dir)
	if not vim.t.project_dir then
		M.set(dir)
	end

	update_frecency(dir)
	require("telescope.builtin").find_files({ cwd = dir })
end

utils.map_keys({
	{ "<leader>p-", goto_project_directory, desc = "Go to project directory" },
})

M.plugin_specs = {
	{
		"synic/telescope-dirpicker.nvim",
		dependencies = { "telescope.nvim" },
		keys = {
			{ "<leader>lt", telescope_new_tab_with_project, desc = "New layout with project" },
			{
				"<leader>*",
				telescope_search_project_cursor_term,
				desc = "Search project for term",
				mode = { "n", "v" },
			},
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

load_frecency()
setup_autochdir()
setup_project_hotkeys()

return M
