local utils = require("ao.utils")
local M = {}

M.install_plugin_manager = function()
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

M.bootstrap_project_list = function(path)
  local project_file_path = vim.fn.stdpath("data") .. "/noun/history"

  if not vim.loop.fs_stat(project_file_path) then
    vim.notify("bootstrapping project list for noun.nvim")
    require("lazy.core.loader").load({ "noun.nvim" }, {})
    local status, history = pcall(require, "noun.utils.history")

    if not status then
      vim.notify("unable to load noun to populate project list", vim.log.levels.ERROR)
      return
    end

    local handle = io.open(project_file_path, "w")

    if not handle then
      vim.notify("Could not open project history file for writing", vim.log.levels.ERROR)
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

M.load_plugin_specs = function()
  local plugins = {}
  local path = vim.fn.stdpath("config") .. "/lua/ao/modules"
  local items = vim.split(vim.fn.glob(vim.fn.resolve(path .. "/*.lua")), "\n", { trimempty = true })

  for _, item in ipairs(items) do
    local m = require("ao.modules." .. vim.fn.fnamemodify(item, ":t:r"))
    local v = m.plugin_specs

    if v == nil then
      plugins = utils.table_concat(plugins, m)
    else
      plugins = utils.table_concat(plugins, (type(v) == "function" and v() or v))
    end
  end

  return plugins
end

M.setup = function(config, startup_callback_fn)
  if config.guifont then
    vim.api.nvim_set_option("guifont", config.guifont)
  end

  local lazy, installed = M.install_plugin_manager()
  local plugins = M.load_plugin_specs()

  lazy.setup(plugins, {
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

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      if startup_callback_fn then
        startup_callback_fn()
      end

      if config.projects_directory then
        M.bootstrap_project_list(config.projects_directory)
      end

      if config.theme then
        require("lazy.core.loader").colorscheme(config.theme)
        vim.schedule(function()
          vim.cmd.colorscheme(config.theme)
        end)
      end
    end,
  })

  lazy.install({ wait = installed, show = false })

  utils.close_all_floating_windows()
end

return M
