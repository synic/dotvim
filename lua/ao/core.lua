local utils = require("ao.utils")
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

module.setup = function(config)
  local keymap = require("ao.keymap")

  if config.guifont then
    vim.api.nvim_set_option("guifont", config.guifont)
  end

  local lazy, installed = module.install_plugin_manager()

  lazy.setup("ao.modules", {
    install = { install_missing = false },
    change_detection = { enabled = true, notify = false },
  })

  lazy.install({ wait = installed, show = false })

  if config.projects_directory then
    module.boostrap_project_list(config.projects_directory)
  end

  module.install_keymap(keymap.general_keys)
  utils.close_all_floating_windows()

  if config.theme then
    utils.lazy_load_theme(config.theme)
  end

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = module.setup_alternate_colors,
  })
end

module.setup_alternate_colors = function()
  vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#444444" })
end

return module
