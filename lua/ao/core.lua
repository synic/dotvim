local utils = require("ao.utils")
local config = require("ao.config")
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

local function load_theme(theme)
  require("lazy.core.loader").colorscheme(theme)
  local status = pcall(vim.cmd.colorscheme, theme)
  if not status then
    vim.notify("Unable to load colorscheme " .. theme, vim.log.levels.ERROR)
  end

  return status
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

M.setup = function(opts, startup_callback_fn)
  if opts.guifont then
    vim.api.nvim_set_option("guifont", opts.guifont)
  end
  config.options = vim.tbl_deep_extend("force", config.options, opts)

  local lazy, installed = M.install_plugin_manager()

  lazy.setup(M.load_plugin_specs(), {
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

  lazy.install({ wait = installed, show = installed })

  local theme_load_status = false
  if opts.theme then
    theme_load_status = load_theme(opts.theme)
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      if startup_callback_fn then
        startup_callback_fn()
      end

      if opts.theme and not theme_load_status then
        require("lazy.core.loader").colorscheme(opts.theme)
        vim.schedule(function()
          vim.cmd.colorscheme(opts.theme)
        end)
      end
    end,
  })

  utils.close_all_floating_windows()
end

return M
