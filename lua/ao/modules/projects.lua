local config = require("ao.config")
local interface = require("ao.modules.interface")
local utils = require("ao.utils")

local M = { plugin_specs = {} }
local root_cache = {}

local function get_buffer_path(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or vim.fn.bufnr())

  if not path or path == "" then
    path = vim.loop.cwd()
  elseif path:find("^oil:") then
    path = utils.remove_oil(path)
  else
    path = vim.fs.dirname(path)
  end

  return path
end

function M.find_path_root(path)
  local root = root_cache[path]

  if root ~= nil then
    return root
  end

  root = vim.fs.find(config.options.projects.root_names, { path = path, upward = true })[1]

  if root ~= nil then
    root = vim.fs.dirname(root)
  end

  root_cache[path] = root
  return root
end

function M.find_buffer_root(bufnr)
  return M.find_path_root(get_buffer_path(bufnr))
end

function M.open(dir)
  local has_builtin, builtin = pcall(require, "telescope.builtin")
  local was_set = interface.set_tab_name(vim.fn.fnamemodify(dir, ":t"))

  if was_set then
    vim.cmd.tcd(dir)
  end

  if has_builtin then
    builtin.find_files({ cwd = dir })
  else
    vim.cmd.edit(dir)
  end
end

return M
