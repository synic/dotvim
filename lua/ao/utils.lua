local module = {}

module.install_plugin_manager = function()
  local was_installed = false
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

    was_installed = true
  end

  vim.opt.rtp:prepend(lazypath)

  local lazy = require("lazy")
  return lazy, was_installed
end

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

module.boostrap_project_list = function(path)
  local project_file_path = vim.fn.stdpath("data") .. "/project_nvim/project_history"
  if not vim.loop.fs_stat(project_file_path) then
    local status, history = pcall(require, "project_nvim.utils.history")

    if not status then
      return
    end

    local handle = io.open(project_file_path, "w")

    if not handle then
      print("Could not open project history file for writing")
      return
    end

    local pfile = io.popen("ls -d1 " .. path .. "/*")

    if pfile == nil then
      return
    end

    for filename in pfile:lines() do
      if vim.loop.fs_stat(filename .. "/.git") then
        handle:write(filename .. "\n")
        table.insert(history.session_projects, filename)
      end
    end

    handle:close()
    history.read_projects_from_history()
  end
end

module.install_keymap = function(keymap)
  local wk_data = {}

  for key, data in pairs(keymap) do
    local keys = data.keys or {}
    if key ~= "misc" then
      data.keys = nil
      wk_data[key] = data
    end

    local modes = data.modes or { "n" }

    for _, mode in pairs(modes) do
      for _, key_data in pairs(keys) do
        local left = key_data[1]
        local right = key_data[2]

        key_data.modes = nil
        key_data[1] = nil
        key_data[2] = nil
        vim.keymap.set(mode, left, right, key_data)
      end
    end

    local status, wk = pcall(require, "which-key")
    if status then
      wk.register(wk_data)
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

return module
