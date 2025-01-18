---@alias KeymapOpts { buffer?: boolean, desc?: string, expr?: boolean, modes?: string[], silent?: boolean, test?: boolean }
---@alias Keymap { [1]: string, [2]: string|function, desc?: string, buffer?: boolean, expr?: boolean, mode?: string[], silent?: boolean, test?: boolean|number }

local uv = vim.uv or vim.loop
local init_group = vim.api.nvim_create_augroup("UtilsOnLoad", { clear = true })

local M = {}

---@return nil
function M.get_help()
	---@diagnostic disable-next-line: missing-fields
	vim.ui.input({ prompt = "enter search term" }, function(input)
		if input == nil then
			return
		end
		vim.cmd("help " .. input)
	end)
end

---@return nil
function M.close_all_floating_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then -- is_floating_window?
			vim.api.nvim_win_close(win, false) -- do not force
		end
	end
end

---@param keymap Keymap[]
---@return nil
function M.map_keys(keymap)
	for _, key_data in ipairs(keymap) do
		local mode = key_data.mode or { "n" }
		local should_apply = true

		if key_data.test ~= nil then
			should_apply = key_data.test ~= 0 and key_data.test ~= nil
			key_data.test = nil
		end

		key_data.mode = nil

		if should_apply then
			local left = key_data[1]
			local right = key_data[2]

			key_data[1] = nil
			key_data[2] = nil

			for _, m in ipairs(mode) do
				vim.keymap.set(m, left, right, key_data)
			end
		end
	end
end

---@param str string
---@return string
function M.basename(str)
	---@diagnostic disable-next-line: redundant-return-value
	return string.gsub(str, "(.*/)(.*)", "%2")
end

---@param ... string
---@return string
function M.join_paths(...)
	local result = table.concat({ ... }, "/")
	return result
end

---@param table1 table
---@param table2 table
---@return table
function M.table_concat(table1, table2)
	for i = 1, #table2 do
		table1[#table1 + 1] = table2[i]
	end
	return table1
end

---@param tbl table
---@param value any
---@return boolean
function M.table_contains(tbl, value)
	for i = 1, #tbl do
		if tbl[i] == value then
			return true
		end
	end
	return false
end

function M.scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "' .. directory .. '"')

	if pfile == nil then
		return {}
	end

	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end

	if pfile ~= nil then
		pfile:close()
	end

	return t
end

function M.on_load(name, callback)
	local has_lazy, config = pcall(require, "lazy.core.config")

	-- if it's already loaded, then just run the callback
	if has_lazy then
		if config.plugins[name]._.loaded ~= nil then
			callback(name)
			return
		end
	end

	vim.api.nvim_create_autocmd("User", {
		group = init_group,
		pattern = "LazyLoad",
		callback = function(event)
			if event.data == name then
				callback(name)
				return true
			end
		end,
	})
end

function M.set_tab_var(tabnr, key, value)
	local handle = vim.api.nvim_list_tabpages()[tabnr or vim.fn.tabpagenr()]
	if handle == nil then
		return
	end
	vim.api.nvim_tabpage_set_var(handle, key, value)
end

function M.set_buf_var(bufnr, key, value)
	local handle = vim.api.nvim_list_bufs()[bufnr or vim.fn.bufnr()]
	if handle == nil then
		return
	end
	vim.api.nvim_buf_set_var(handle, key, value)
end

function M.remove_oil(path)
	if path == "oil:" then
		return true, "/"
	elseif path:find("^oil://") then
		return true, string.sub(path, 7)
	end
	return false, path
end

function M.is_new_file()
	local filename = vim.fn.expand("%")
	return filename ~= "" and vim.bo.buftype == "" and vim.fn.filereadable(filename) == 0
end

function M.get_buffer_cwd(bufnr, winnr)
	local path = vim.api.nvim_buf_get_name(bufnr or 0)

	if not path or path == "" then
		-- only check cwd if bufnr wasn't passed
		if not bufnr then
			path = vim.fn.getcwd(winnr or 0)
		end
	elseif path:find("^oil:") then
		_, path = M.remove_oil(path)
	else
		path = vim.fs.dirname(path)
	end

	return path
end

function M.normalize_path(path, cwd)
	return require("plenary.path"):new(path):normalize(cwd or uv.cwd())
end

return M
