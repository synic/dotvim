local utils = require("ao.utils")
local config = require("ao.config")
local interface = require("ao.modules.interface")
local M = { plugin_specs = {} }
local root_cache = {}

local function get_oil_dir()
  local has_oil, oil = pcall(require, "oil")

  if not has_oil or not oil.get_current_dir() then
    return nil
  end

  local entry = oil.get_cursor_entry()
  if entry then
    return vim.fn.resolve(oil.get_current_dir() .. "/" .. entry.name)
  else
    return oil.get_current_dir()
  end
end

M.find_root = function(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or vim.fn.bufnr())
  if not path or path == "" then
    return ""
  end

  local cache_key = path
  local cached_root = root_cache[cache_key]

  if cached_root ~= nil then
    return cached_root
  end

  local oildir = get_oil_dir()
  path = oildir and oildir or vim.fs.dirname(utils.normalize_path(path))

  local root = nil
  local root_file = vim.fs.find(config.options.projects.root_names, { path = path, upward = true })[1]

  if root_file == nil then
    return nil
  else
    root = vim.fs.dirname(root_file)
  end

  root_cache[cache_key] = root

  return root
end

M.open = function(dir)
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
