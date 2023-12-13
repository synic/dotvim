local utils = require("ao.utils")

local categories = {
  ["<leader>"] = {
    b = { name = "+buffers" },
    w = { name = "+windows" },
    l = { name = "+layouts/tabs" },
    d = { name = "+debug" },
    h = { name = "+help" },
    g = { name = "+git" },
    s = { name = "+search" },
    p = { name = "+project" },
    t = { name = "+toggles" },
    u = { name = "+ui" },
    e = { name = "+diagnostis" },
    P = { name = "+plugins" },
    c = { name = "+configuration", p = { name = "+plugins" } },
    q = { name = "+quit" },
    x = { name = "+misc" },
  },
  ["<localleader>"] = {
    g = { name = "+git", h = { name = "+hunks" } },
  },
}

utils.map_keys({
  -- windows
  { "<leader>wk", "<cmd>wincmd k<cr>", desc = "move up", silent = true },
  { "<leader>wj", "<cmd>wincmd j<cr>", desc = "move down", silent = true },
  { "<leader>wh", "<cmd>wincmd h<cr>", desc = "move left", silent = true },
  { "<leader>wl", "<cmd>wincmd l<cr>", desc = "move right", silent = true },
  { "<leader>w/", "<cmd>vs<cr>", desc = "split vertically", silent = true },
  { "<leader>w-", "<cmd>sp<cr>", desc = "split horizontally", silent = true },
  { "<leader>wc", "<cmd>close<cr>", desc = "close window", silent = true },
  { "<leader>wd", "<cmd>q<cr>", desc = "quit window", silent = true },
  { "<leader>w=", "<C-w>=", desc = "equalize windows", silent = true },
  { "<leader>wm", "<C-w>|", desc = "maximize window", silent = true },
  { "<leader>wH", "<cmd>wincmd H<cr>", desc = "move window left", silent = true },
  { "<leader>wJ", "<cmd>wincmd J<cr>", desc = "move window down", silent = true },
  { "<leader>wK", "<cmd>wincmd K<cr>", desc = "move window up", silent = true },
  { "<leader>wL", "<cmd>wincmd L<cr>", desc = "move window right", silent = true },
  { "<leader>wR", "<cmd>wincmd R<cr>", desc = "rotate windows", silent = true },
  { "<leader>wT", "<cmd>wincmd T<cr>", desc = "move to new layout", silent = true },

  -- layouts/tabs
  { "<leader>lT", "<cmd>tabnew<cr>", desc = "new layout", silent = true },
  { "<leader>l1", "1gt", desc = "go to layout #1", silent = true },
  { "<leader>l2", "2gt", desc = "go to layout #2", silent = true },
  { "<leader>l3", "3gt", desc = "go to layout #3", silent = true },
  { "<leader>l4", "4gt", desc = "go to layout #4", silent = true },
  { "<leader>l5", "5gt", desc = "go to layout #5", silent = true },
  { "<leader>l6", "6gt", desc = "go to layout #6", silent = true },
  { "<leader>l7", "7gt", desc = "go to layout #7", silent = true },
  { "<leader>l8", "8gt", desc = "go to layout #8", silent = true },
  { "<leader>l9", "9gt", desc = "go to layout #9", silent = true },
  { "<leader>lc", "<cmd>tabclose<cr>", desc = "close layout", silent = true },
  { "<leader>ln", "<cmd>tabnext<cr>", desc = "next layout", silent = true },
  { "<leader>lp", "<cmd>tabprev<cr>", desc = "previous layout", silent = true },

  -- toggles
  { "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "toggle search highlights", silent = true },
  { "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "toggle relative line numbers", silent = true },
  { "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "toggle line number display", silent = true },
  { "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "toggle tab display", silent = true },

  -- buffers
  { "<leader><tab>", "<cmd>b#<cr>", desc = "previous buffer", silent = true },
  { "<leader>bd", "<cmd>bdelete!<cr>", desc = "close current window and quit buffer", silent = true },
  { "<leader>bp", "1<C-g>:<C-U>echo v:statusmsg<cr>", desc = "show full buffer path", silent = true },
  { "<leader>bn", "<cmd>enew<cr>", desc = "new buffer", silent = true },

  -- help
  { "<leader>hh", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "show help", silent = true },

  -- misc
  {
    "<leader>cm",
    "<cmd>lua vim.cmd('edit ' .. vim.fn.stdpath('config'))<cr>",
    desc = "manage config",
  },

  { "vig", "ggVG", desc = "select whole buffer", silent = true },
  { "<leader><localleader>", "<localleader>", desc = "local buffer options", silent = true },
  {
    "<leader>xx",
    "<cmd>lua require('ao.utils').close_all_floating_windows()<cr>",
    desc = "close floating windows",
  },
  { "<leader>qq", "<cmd>qa!<cr>", desc = "quit" },
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
