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
  local status, history = pcall(require, "project_nvim.utils.history")

  if not status then
    return
  end

  local project_file_path = vim.fn.stdpath("data") .. "/project_nvim/project_history"
  if not vim.loop.fs_stat(project_file_path) then
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

    if handle then
      handle:close()
      history.read_projects_from_history()
      print(vim.inspect(history.session_projects))
    end
  end
end

return module
