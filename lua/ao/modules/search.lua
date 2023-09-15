local utils = require("ao.utils")
local keymap = require("ao.keymap")
local module = {}

module.search_in_project_root = function()
  vim.ui.input({ prompt = "term: " }, function(input)
    vim.cmd('CtrlSF "' .. input .. '"')
  end)
end

return utils.table_concat(module, {
  {
    "dyng/ctrlsf.vim",
    cmd = { "CtrlSF" },
    keys = keymap.ctrlsf,
    init = function()
      vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
      vim.g.ctrlsf_default_view_mode = "normal"
      vim.g.ctrlsf_default_root = "project+wf"
      vim.g.ctrlsf_auto_close = {
        normal = 0,
        compact = 1,
      }
      vim.g.ctrlsf_auto_focus = {
        at = "start",
      }
    end,
  },
  "haya14busa/incsearch.vim",
})
