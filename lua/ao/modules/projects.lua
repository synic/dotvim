local config = require("ao.config")
local utils = require("ao.utils")

local M = { plugin_specs = {} }
local root_cache = {}

local function get_buffer_path(bufnr, winnr)
  local path = vim.api.nvim_buf_get_name(bufnr or 0)

  if not path or path == "" then
    -- only check cwd if bufnr wasn't passed
    if not bufnr then
      path = vim.fn.getcwd(winnr or 0)
    end
  elseif path:find("^oil:") then
    _, path = utils.remove_oil(path)
  else
    path = vim.fs.dirname(path)
  end

  return path
end

function M.find_path_root(path)
  if not path or path == "" then
    return nil
  end
  local root = root_cache[path]

  if root ~= nil then
    if root == -1 then
      return nil
    end
    return root
  end

  root = vim.fs.find(config.options.projects.root_names, { path = path, upward = true })[1]

  if root ~= nil then
    root = vim.fs.dirname(root)
  end

  root_cache[path] = root or -1
  return root
end

function M.find_buffer_root(bufnr)
  return M.find_path_root(get_buffer_path(bufnr))
end

function M.get_dir(tabnr)
  local path = M.find_path_root(vim.fn.getcwd(-1, tabnr or 0))
  return path
end

function M.get_name(tabnr)
  local path = M.get_dir(tabnr)
  return path and vim.fs.basename(path) or nil
end

function M.set(dir)
  vim.t.projectset = true
  vim.cmd.tcd(dir)
  vim.cmd.redrawtabline()
end

function M.open(dir)
  if not vim.t.projectset then
    M.set(dir)
  end

  require("telescope.builtin").find_files({ cwd = dir })
end

local chdir_aucmds = { "BufEnter", "VimEnter" }

for _, aucmd in ipairs(chdir_aucmds) do
  vim.api.nvim_create_autocmd(aucmd, {
    callback = function()
      local root = M.find_buffer_root()
      if root and root ~= nil then
        vim.cmd.lcd(root)
      end
    end,
  })
end

return M
