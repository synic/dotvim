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

return module
