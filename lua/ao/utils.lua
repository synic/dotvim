local M = {}

M.get_help = function()
  vim.ui.input({ prompt = "enter search term" }, function(input)
    if input == nil then
      return
    end
    vim.cmd("help " .. input)
  end)
end

M.close_all_floating_windows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then -- is_floating_window?
      vim.api.nvim_win_close(win, false) -- do not force
    end
  end
end

M.map_keys = function(keymap)
  for _, key_data in ipairs(keymap) do
    local modes = key_data.modes or { "n" }
    key_data.modes = nil

    local left = key_data[1]
    local right = key_data[2]

    key_data[1] = nil
    key_data[2] = nil

    for _, mode in ipairs(modes) do
      vim.keymap.set(mode, left, right, key_data)
    end
  end
end

M.basename = function(str)
  return string.gsub(str, "(.*/)(.*)", "%2")
end

M.join_paths = function(...)
  local result = table.concat({ ... }, "/")
  return result
end

M.table_concat = function(table1, table2)
  for i = 1, #table2 do
    table1[#table1 + 1] = table2[i]
  end
  return table1
end

M.table_contains = function(tbl, value)
  for i = 1, #tbl do
    if tbl[i] == value then
      return true
    end
  end
  return false
end

M.scandir = function(directory)
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

M.on_load = function(name, callback)
  local status, config = pcall(require, "lazy.core.config")

  -- if it's already loaded, then just run the callback
  if status then
    if config.plugins[name]._.loaded ~= nil then
      callback(name)
      return
    end
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(event)
      if event.data == name then
        callback(name)
        return true
      end
    end,
  })
end

M.get_current_git_branch = function()
  local branch = io.popen("git rev-parse --abbrev-ref HEAD 2> /dev/null")
  if branch then
    local name = branch:read("*l")
    branch:close()
    if name then
      return name
    else
      return ""
    end
  end
end

M.find_project_root = function()
  local status, noun = pcall(require, "noun")

  if not status then
    return
  end

  local root, _ = noun.get_project_root()
  return root
end

M.goto_config_directory = function()
  vim.cmd.tcd(vim.fn.stdpath("config"))
  vim.cmd.edit(".")
end

M.has_module = function(n)
  local status, _ = pcall(require, n)
  return status
end

M.set_tab_var = function(tabnr, key, value)
  local handle = vim.api.nvim_list_tabpages()[tabnr or vim.fn.tabpagenr()]
  vim.api.nvim_tabpage_set_var(handle, key, value)
end

return M
