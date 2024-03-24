local utils = require("ao.utils")
local filesystem = require("ao.modules.filesystem")

local function buffer_show_path(full)
  local pattern = "%p"

  if full then
    pattern = "%:p"
  end

  local path = vim.fn.expand(pattern)
  vim.fn.setreg("+", path)
  vim.notify(path)
  print(path)
end

local function buffer_show_full_path()
  buffer_show_path(true)
end

local categories = {
  ["<leader>"] = {
    b = { "+buffers" },
    w = { "+windows", m = { "+move" } },
    l = { "+layouts" },
    d = { "+debug" },
    h = { "+help" },
    g = { "+git" },
    f = { "+files" },
    s = { "+search" },
    p = { "+project" },
    t = { "+toggles" },
    u = { "+ui" },
    e = { "+diagnostis" },
    c = { "+configuration", p = { "+plugins" } },
    q = { "+quit" },
    ["?"] = { "help" },
  },
}

utils.map_keys({
  -- windows
  { "<leader>wk", "<cmd>wincmd k<cr>", desc = "Go up" },
  { "<leader>wj", "<cmd>wincmd j<cr>", desc = "Go down" },
  { "<leader>wh", "<cmd>wincmd h<cr>", desc = "Go left" },
  { "<leader>wl", "<cmd>wincmd l<cr>", desc = "Go right" },
  { "<leader>w/", "<cmd>vs<cr>", desc = "Split vertically" },
  { "<leader>w-", "<cmd>sp<cr>", desc = "Split horizontally" },
  { "<leader>/", "<cmd>vs<cr>", desc = "Split vertically" },
  { "<leader>-", "<cmd>sp<cr>", desc = "Split horizontally" },
  { "<leader>wc", "<cmd>close<cr>", desc = "Close window" },
  { "<leader>wd", "<cmd>q<cr>", desc = "Quit window" },
  { "<leader>w=", "<C-w>=", desc = "Equalize windows" },
  { "<leader>wH", "<cmd>wincmd h<cr><cmd>close<cr>", desc = "Close window to the left" },
  { "<leader>wJ", "<cmd>wincmd j<cr><cmd>close<cr>", desc = "Close window below" },
  { "<leader>wK", "<cmd>wincmd k<cr><cmd>close<cr>", desc = "Close window above" },
  { "<leader>wL", "<cmd>wincmd l<cr><cmd>close<cr>", desc = "Close window to the right" },
  { "<leader>wmh", "<cmd>wincmd H<cr>", desc = "Move window left" },
  { "<leader>wmj", "<cmd>wincmd J<cr>", desc = "Move window down" },
  { "<leader>wmk", "<cmd>wincmd K<cr>", desc = "Move window up" },
  { "<leader>wml", "<cmd>wincmd L<cr>", desc = "Move window right" },
  { "<leader>wR", "<cmd>wincmd R<cr>", desc = "Rotate windows" },
  { "<leader>wT", "<cmd>wincmd T<cr>", desc = "Move to new layout" },

  -- layouts/tabs
  { "<leader>l.", "<cmd>tabnew<cr>", desc = "New layout" },
  { "<leader>l1", "1gt", desc = "Go to layout #1" },
  { "<leader>l2", "2gt", desc = "Go to layout #2" },
  { "<leader>l3", "3gt", desc = "Go to layout #3" },
  { "<leader>l4", "4gt", desc = "Go to layout #4" },
  { "<leader>l5", "5gt", desc = "Go to layout #5" },
  { "<leader>l6", "6gt", desc = "Go to layout #6" },
  { "<leader>l7", "7gt", desc = "Go to layout #7" },
  { "<leader>l8", "8gt", desc = "Go to layout #8" },
  { "<leader>l9", "9gt", desc = "Go to layout #9" },
  { "<leader>lc", "<cmd>tabclose<cr>", desc = "Close layout" },
  { "<leader>ln", "<cmd>tabnext<cr>", desc = "Next layout" },
  { "<leader>lp", "<cmd>tabprev<cr>", desc = "Previous layout" },
  { "<leader>l<tab>", "g<Tab>", desc = "Go to last layout" },

  -- toggles
  { "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "Toggle search highlights" },
  { "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "Toggle relative line numbers" },
  { "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "Toggle line number display" },
  { "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "Toggle tab display" },

  -- buffers
  { "<leader><tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
  { "<leader>b<tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
  { "<leader>bd", "<cmd>bdelete!<cr>", desc = "Close current window and quit buffer" },
  { "<leader>bp", buffer_show_path, desc = "Show buffer path" },
  { "<leader>bP", buffer_show_full_path, desc = "Show full buffer path" },
  { "<leader>bn", "<cmd>enew<cr>", desc = "New buffer" },

  -- help
  { "<leader>hh", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },
  { "<leader>?", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },

  -- configuration
  { "<leader>cm", filesystem.goto_config_directory, desc = "Manage config" },
  { "<leader>cx", utils.close_all_floating_windows, desc = "Close plugin manager" },
  -- misc

  { "vig", "ggVG", desc = "Select whole buffer" },
  { "<leader><localleader>", "<localleader>", desc = "Local buffer options" },
  { "<leader>qq", "<cmd>qa!<cr>", desc = "Quit Vim" },
})

return {
  -- key hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 700
    end,
    opts = {
      plugins = { spelling = true },
      mode = { "n", "v" },
      layout = { align = "center" },
      triggers_blacklist = {
        i = { "f", "d" },
        v = { "f", "d" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(categories)
    end,
  },
}
