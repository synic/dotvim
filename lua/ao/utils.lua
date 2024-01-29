local module = {}

module.get_help = function()
  vim.ui.input({ prompt = "enter search term" }, function(input)
    vim.cmd("help " .. input)
  end)
end

module.close_all_floating_windows = function()
  local closed_windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then -- is_floating_window?
      vim.api.nvim_win_close(win, false) -- do not force
      table.insert(closed_windows, win)
    end
  end
end

module.map_keys = function(keymap)
  for _, key_data in pairs(keymap) do
    local modes = key_data.modes or { "n" }
    key_data.modes = nil

    local left = key_data[1]
    local right = key_data[2]

    key_data[1] = nil
    key_data[2] = nil

    for _, mode in pairs(modes) do
      vim.keymap.set(mode, left, right, key_data)
    end
  end
end

module.basename = function(str)
  return string.gsub(str, "(.*/)(.*)", "%2")
end

module.join_paths = function(...)
  local result = table.concat({ ... }, "/")
  return result
end

module.table_concat = function(table1, table2)
  for i = 1, #table2 do
    table1[#table1 + 1] = table2[i]
  end
  return table1
end

module.table_contains = function(tbl, value)
  for i = 1, #tbl do
    if tbl[i] == value then
      return true
    end
  end
  return false
end

module.scandir = function(directory)
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

module.on_load = function(name, fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(event)
      if event.data == name then
        fn(name)
        return true
      end
    end,
  })
end

module.branch_name = function()
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

module.find_project_root = function()
  local project_status, project = pcall(require, "project_nvim.project")

  if not project_status then
    return
  end

  local project_root, _ = project.get_project_root()
  return project_root
end

return module
