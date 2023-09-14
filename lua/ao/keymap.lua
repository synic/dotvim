local module = {}
table.unpack = table.unpack or unpack -- stylua: ignore

module.categories = {
  ["g"] = { name = "+goto" },
  ["]"] = { name = "+next" },
  ["["] = { name = "+prev" },
  ["<leader>i"] = { name = "+info" },
  ["<leader>b"] = { name = "+buffers" },
  ["<leader>w"] = { name = "windows/tabs+" },
  ["<leader>d"] = { name = "+debug" },
  ["<leader>h"] = { name = "+help" },
  ["<leader>g"] = { name = "+git" },
  ["<leader>s"] = { name = "+search" },
  ["<leader>t"] = { name = "+toggles" },
  ["<leader>u"] = { name = "+ui" },
  ["<leader>e"] = { name = "+diagnostis" },
  ["<leader>P"] = { name = "+plugins" },
  ["<leader>c"] = { name = "+code" },
  ["<leader>q"] = { name = "+quit" },
  [",d"] = { name = "+definitions" },
}

local keymap = {
  -- window management
  { "n", "<leader>wk", "<cmd>wincmd k<cr>", { desc = "move cursor up one window", silent = true } },
  { "n", "<leader>wj", "<cmd>wincmd j<cr>", { desc = "move cursor down one window", silent = true } },
  { "n", "<leader>wh", "<cmd>wincmd h<cr>", { desc = "move cursor left one window", silent = true } },
  { "n", "<leader>wl", "<cmd>wincmd l<cr>", { desc = "move cursor right one window", silent = true } },
  { "n", "<leader>w/", "<cmd>vs<cr>", { desc = "split window vertically", silent = true } },
  { "n", "<leader>w-", "<cmd>sp<cr>", { desc = "split window horizontally", silent = true } },
  { "n", "<leader>wc", "<cmd>close<cr>", { desc = "close current window", silent = true } },
  { "n", "<leader>wd", "<cmd>q<cr>", { desc = "close current window and quit buffer", silent = true } },
  { "n", "<leader>w=", "<C-w>=", { desc = "equalize windows", silent = true } },
  { "n", "<leader>wm", "<C-w>|", { desc = "maximize window", silent = true } },

  -- buffer management
  { "n", "<leader><tab>", "<cmd>b#<cr>", { desc = "previous buffer", silent = true } },
  { "n", "<leader>bd", "<cmd>bdelete!<cr>", { desc = "close current window and quit buffer", silent = true } },

  -- config management
  {
    "n",
    "<leader>C",
    "<cmd>lua vim.cmd('edit ' .. vim.fn.stdpath('config'))<cr>",
    { desc = "manage config" },
  },

  -- toggles
  { "n", "<leader>ts", "<cmd>let &hls = !&hls<cr>", { desc = "toggle search highlights", silent = true } },
  { "n", "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", { desc = "toggle relative line numbers", silent = true } },
  { "n", "<leader>tn", "<cmd>let &nu = !&nu<cr>", { desc = "toggle line number display", silent = true } },
  { "n", "<leader>tt", "<cmd>let &stal = !&stal<cr>", { desc = "toggle tab display", silent = true } },

  -- layouts/tabs
  { "n", "<leader>wT", "<cmd>tabnew<cr>", { desc = "new tab", silent = true } },
  { "n", "<leader>w1", "1gt", { desc = "go to tab #1", silent = true } },
  { "n", "<leader>w2", "2gt", { desc = "go to tab #2", silent = true } },
  { "n", "<leader>w3", "3gt", { desc = "go to tab #3", silent = true } },
  { "n", "<leader>w4", "4gt", { desc = "go to tab #4", silent = true } },
  { "n", "<leader>w5", "5gt", { desc = "go to tab #5", silent = true } },
  { "n", "<leader>w6", "6gt", { desc = "go to tab #6", silent = true } },
  { "n", "<leader>w7", "7gt", { desc = "go to tab #7", silent = true } },
  { "n", "<leader>w8", "8gt", { desc = "go to tab #8", silent = true } },
  { "n", "<leader>w9", "9gt", { desc = "go to tab #9", silent = true } },
  { "n", "<leader>wC", "<cmd>tabclose<cr>", { desc = "close tab", silent = true } },

  -- netrw/files
  { "", "-", "<cmd>execute 'edit ' . expand('%:p%:h')<cr>", { desc = "browse current directory", silent = true } },

  -- help
  { "n", "<leader>hh", "<cmd>lua require('ao.core.functions').get_help()<cr>", { desc = "show help", silent = true } },

  -- misc
  { "n", "<leader>bp", "1<C-g>:<C-U>echo v:statusmsg<cr>", { desc = "show full buffer path", silent = true } },
  { "n", "<leader>bn", "<cmd>enew<cr>", { desc = "new buffer", silent = true } },
  { "n", "vig", "ggVG", { desc = "select whole buffer", silent = true } },
  { "n", "<leader><localleader>", "<localleader>", { desc = "local buffer options", silent = true } },
  {
    "n",
    "<leader>X",
    "<cmd>lua require('ao.core.functions').close_all_floating_windows()<cr>",
    { desc = "close floating windows" },
  },
  { "n", "<leader>qq", "<cmd>qa!<cr>", { desc = "quit" } },
}

for _, item in pairs(keymap) do
  vim.api.nvim_set_keymap(table.unpack(item))
end

return module
