local module = {}
table.unpack = table.unpack or unpack

module.categories = {
	["g"] = { name = "+goto" },
	["gz"] = { name = "+surround" },
	["]"] = { name = "+next" },
	["["] = { name = "+prev" },
	["<space>rl"] = { name = "show last search" },
	["<space>P"] = { name = "manage plugins" },
	["<space>l"] = { name = "+layouts" },
	["<space>b"] = { name = "+buffers" },
	["<space>i"] = { name = "+info" },
	["<space>d"] = { name = "+debug" },
	["<space>fe"] = { name = "+misc" },
	["<space>h"] = { name = "+help" },
	["<space>p"] = { name = "+project" },
	["<space>g"] = { name = "+git" },
	["<space>s"] = { name = "+search" },
	["<space>t"] = { name = "+toggles" },
	["<space>u"] = { name = "+ui" },
	["<space>w"] = { name = "+windows" },
	["<space>e"] = { name = "+diagnostis/quickfix" },
	["<leader>gh"] = { name = "+hunks" },
}

local keymap = {
	-- window management
	{ "n", "<space>wk", "<cmd>wincmd k<cr>", { desc = "move cursor up one window", silent = true } },
	{ "n", "<space>wj", "<cmd>wincmd j<cr>", { desc = "move cursor down one window", silent = true } },
	{ "n", "<space>wh", "<cmd>wincmd h<cr>", { desc = "move cursor left one window", silent = true } },
	{ "n", "<space>wl", "<cmd>wincmd l<cr>", { desc = "move cursor right one window", silent = true } },
	{ "n", "<space>w/", "<cmd>vs<cr>", { desc = "split window vertically", silent = true } },
	{ "n", "<space>w-", "<cmd>sp<cr>", { desc = "split window horizontally", silent = true } },
	{ "n", "<space>wc", "<cmd>close<cr>", { desc = "close current window", silent = true } },
	{ "n", "<space>wd", "<cmd>q<cr>", { desc = "close current window and quit buffer", silent = true } },
	{ "n", "<space>w=", "<C-w>=", { desc = "equalize windows", silent = true } },

	-- buffer management
	{ "n", "<space><tab>", "<cmd>b#<cr>", { desc = "previous buffer", silent = true } },
	{ "n", "<space>bd", "<cmd>q<cr>", { desc = "close current window and quit buffer", silent = true } },

	-- config management
	{ "n", "<space>fed", "<cmd>e $VIMHOME/<cr>", { desc = "go to config directory", silent = true } },

	-- toggles
	{ "n", "<space>ts", "<cmd>let &hls = !&hls<cr>", { desc = "toggle search highlights", silent = true } },
	{ "n", "<space>tr", "<cmd>let &rnu = !&rnu<cr>", { desc = "toggle relative line numbers", silent = true } },
	{ "n", "<space>tn", "<cmd>let &nu = !&nu<cr>", { desc = "toggle line number display", silent = true } },

	-- netrw
	{ "", "-", "<cmd>execute 'edit ' . expand('%:p%:h')<cr>", { desc = "browse current directory", silent = true } },

	-- layouts
	{ "n", "<space>l1", "1gt", { desc = "go to layout #1", silent = true } },
	{ "n", "<space>l2", "2gt", { desc = "go to layout #2", silent = true } },
	{ "n", "<space>l3", "3gt", { desc = "go to layout #3", silent = true } },
	{ "n", "<space>l4", "4gt", { desc = "go to layout #4", silent = true } },
	{ "n", "<space>l5", "5gt", { desc = "go to layout #5", silent = true } },
	{ "n", "<space>l6", "6gt", { desc = "go to layout #6", silent = true } },
	{ "n", "<space>l7", "7gt", { desc = "go to layout #7", silent = true } },
	{ "n", "<space>l8", "8gt", { desc = "go to layout #8", silent = true } },
	{ "n", "<space>l9", "9gt", { desc = "go to layout #9", silent = true } },

	-- help
	{ "n", "<space>hh", "<cmd>help<cr>", { desc = "show help", silent = true } },

	-- misc
	{ "n", "<space>ib", "1<C-g>:<C-U>echo v:statusmsg<cr>", { desc = "show full buffer path", silent = true } },
	{ "n", "vig", "ggVG", { desc = "select whole buffer", silent = true } },
}

for _, item in pairs(keymap) do
	vim.api.nvim_set_keymap(table.unpack(item))
end

return module
