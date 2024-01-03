local utils = require("ao.utils")

local function buffer_show_name(full_path)
  local pattern = "%p"

  if full_path then
    pattern = "%:p"
  end

  local path = vim.fn.expand(pattern)
  vim.fn.setreg("+", path)
  print(path)
end

local categories = {
  ["<leader>"] = {
    b = { "+buffers" },
    w = { "+windows" },
    l = { "+layouts/tabs" },
    d = { "+debug" },
    h = { "+help" },
    g = { "+git" },
    s = { "+search" },
    p = { "+project" },
    t = { "+toggles" },
    u = { "+ui" },
    e = { "+diagnostis" },
    P = { "+plugins" },
    c = { "+configuration", P = { "+plugins" } },
    q = { "+quit" },
    x = { "+misc" },
  },
  ["<localleader>"] = {
    g = { "+git", h = { "+hunks" } },
  },
}

utils.map_keys({
  -- windows
  { "<leader>wk", "<cmd>wincmd k<cr>", desc = "Go up", silent = true },
  { "<leader>wj", "<cmd>wincmd j<cr>", desc = "Go down", silent = true },
  { "<leader>wh", "<cmd>wincmd h<cr>", desc = "Go left", silent = true },
  { "<leader>wl", "<cmd>wincmd l<cr>", desc = "Go right", silent = true },
  { "<leader>w/", "<cmd>vs<cr>", desc = "Split vertically", silent = true },
  { "<leader>w-", "<cmd>sp<cr>", desc = "Split horizontally", silent = true },
  { "<leader>wc", "<cmd>close<cr>", desc = "Close window", silent = true },
  { "<leader>wd", "<cmd>q<cr>", desc = "Quit window", silent = true },
  { "<leader>w=", "<C-w>=", desc = "Equalize windows", silent = true },
  { "<leader>wm", "<C-w>|", desc = "Maximize window", silent = true },
  { "<leader>wH", "<cmd>wincmd H<cr>", desc = "Move window left", silent = true },
  { "<leader>wJ", "<cmd>wincmd J<cr>", desc = "Move window down", silent = true },
  { "<leader>wK", "<cmd>wincmd K<cr>", desc = "Move window up", silent = true },
  { "<leader>wL", "<cmd>wincmd L<cr>", desc = "Move window right", silent = true },
  { "<leader>wR", "<cmd>wincmd R<cr>", desc = "Rotate windows", silent = true },
  { "<leader>wT", "<cmd>wincmd T<cr>", desc = "Move to new layout", silent = true },

  -- layouts/tabs
  { "<leader>lT", "<cmd>tabnew<cr>", desc = "New layout", silent = true },
  { "<leader>l1", "1gt", desc = "Go to layout #1", silent = true },
  { "<leader>l2", "2gt", desc = "Go to layout #2", silent = true },
  { "<leader>l3", "3gt", desc = "Go to layout #3", silent = true },
  { "<leader>l4", "4gt", desc = "Go to layout #4", silent = true },
  { "<leader>l5", "5gt", desc = "Go to layout #5", silent = true },
  { "<leader>l6", "6gt", desc = "Go to layout #6", silent = true },
  { "<leader>l7", "7gt", desc = "Go to layout #7", silent = true },
  { "<leader>l8", "8gt", desc = "Go to layout #8", silent = true },
  { "<leader>l9", "9gt", desc = "Go to layout #9", silent = true },
  { "<leader>lc", "<cmd>tabclose<cr>", desc = "Close layout", silent = true },
  { "<leader>ln", "<cmd>tabnext<cr>", desc = "Next layout", silent = true },
  { "<leader>lp", "<cmd>tabprev<cr>", desc = "Previous layout", silent = true },

  -- toggles
  { "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "Toggle search highlights", silent = true },
  { "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "Toggle relative line numbers", silent = true },
  { "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "Toggle line number display", silent = true },
  { "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "Toggle tab display", silent = true },

  -- buffers
  { "<leader><tab>", "<cmd>b#<cr>", desc = "Previous buffer", silent = true },
  { "<leader>bd", "<cmd>bdelete!<cr>", desc = "Close current window and quit buffer", silent = true },
  { "<leader>bp", buffer_show_name, desc = "Show buffer path", silent = true },
  {
    "<leader>bP",
    function()
      buffer_show_name(true)
    end,
    desc = "Show full buffer path",
    silent = true,
  },
  { "<leader>bn", "<cmd>enew<cr>", desc = "New buffer", silent = true },

  -- help
  { "<leader>hh", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help", silent = true },

  -- configuration
  {
    "<leader>cm",
    "<cmd>lua vim.cmd('edit ' .. vim.fn.stdpath('config'))<cr>",
    desc = "Manage config",
  },

  -- misc

  { "vig", "ggVG", desc = "Select whole buffer", silent = true },
  { "<leader><localleader>", "<localleader>", desc = "Local buffer options", silent = true },
  {
    "<leader>xx",
    "<cmd>lua require('ao.utils').close_all_floating_windows()<cr>",
    desc = "Close floating windows",
  },
  { "<leader>qq", "<cmd>qa!<cr>", desc = "Quit Vim" },
})

return {
  -- key hints
  {
    "folke/which-key.nvim",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 700
    end,
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(categories)
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
  },
}
