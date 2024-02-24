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
  local project_file_path = vim.fn.stdpath("data") .. "/noun/history"
  if not vim.loop.fs_stat(project_file_path) then
    local status, history = pcall(require, "noun.utils.history")

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

module.setup = function(config)
  if config.guifont then
    vim.api.nvim_set_option("guifont", config.guifont)
  end

  local lazy, installed = module.install_plugin_manager()

  lazy.setup("ao.modules", {
    install = { install_missing = false },
    change_detection = {
      -- with change detection enabled, lazy.nvim does something when you save
      -- lua files that are modules. whatever it does, it wipes out the none-ls
      -- autocmd that is set up to format on save. It also causes other events to
      -- attach more than once (gitsigns). better to just leave it off.
      enabled = false,
      notify = false,
    },
  })

  lazy.install({ wait = installed, show = false })

  if config.projects_directory then
    module.boostrap_project_list(config.projects_directory)
  end

  utils.close_all_floating_windows()

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = module.setup_alternate_colors,
  })

  if config.theme then
    vim.cmd.colorscheme(config.theme)
  end
end

module.setup_alternate_colors = function()
  vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
  vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
end

return module
