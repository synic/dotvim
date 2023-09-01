local module = {}
table.unpack = table.unpack or unpack

module.categories = {
	["g"] = { name = "+goto" },
	["gz"] = { name = "+surround" },
	["]"] = { name = "+next" },
	["["] = { name = "+prev" },
	["<space>P"] = { name = "manage plugins" },
	["<space>C"] = { name = "manage configuration" },
	["<space>l"] = { name = "+list" },
	["<space>t"] = { name = "+tabs" },
	["<space>b"] = { name = "+buffers" },
	["<space>i"] = { name = "+info" },
	["<leader>d"] = { name = "+debug" },
	["<space>n"] = { name = "+notifications" },
	["<space>h"] = { name = "+help" },
	["<space>p"] = { name = "+project" },
	["<space>g"] = { name = "+git" },
	["<space>s"] = { name = "+search" },
	["<leader>t"] = { name = "+toggles" },
	["<space>u"] = { name = "+ui" },
	["<space>w"] = { name = "+windows" },
	["<space>e"] = { name = "+diagnostis/quickfix" },
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
	{ "n", "<space>bd", "<cmd>bdelete<cr>", { desc = "close current window and quit buffer", silent = true } },

	-- config management
	{ "n", "<space>C", "<cmd>e $VIMHOME/<cr>", { desc = "go to config directory", silent = true } },

	-- toggles
	{ "n", "<leader>ts", "<cmd>let &hls = !&hls<cr>", { desc = "toggle search highlights", silent = true } },
	{ "n", "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", { desc = "toggle relative line numbers", silent = true } },
	{ "n", "<leader>tn", "<cmd>let &nu = !&nu<cr>", { desc = "toggle line number display", silent = true } },

	-- netrw/files
	{ "", "-", "<cmd>execute 'edit ' . expand('%:p%:h')<cr>", { desc = "browse current directory", silent = true } },

	-- layouts
	{ "n", "<space>t1", "1gt", { desc = "go to tab #1", silent = true } },
	{ "n", "<space>t2", "2gt", { desc = "go to tab #2", silent = true } },
	{ "n", "<space>t3", "3gt", { desc = "go to tab #3", silent = true } },
	{ "n", "<space>t4", "4gt", { desc = "go to tab #4", silent = true } },
	{ "n", "<space>t5", "5gt", { desc = "go to tab #5", silent = true } },
	{ "n", "<space>t6", "6gt", { desc = "go to tab #6", silent = true } },
	{ "n", "<space>t7", "7gt", { desc = "go to tab #7", silent = true } },
	{ "n", "<space>t8", "8gt", { desc = "go to tab #8", silent = true } },
	{ "n", "<space>t9", "9gt", { desc = "go to tab #9", silent = true } },

	-- help
	{ "n", "<space>hh", "<cmd>help<cr>", { desc = "show help", silent = true } },

	-- misc
	{ "n", "<space>bp", "1<C-g>:<C-U>echo v:statusmsg<cr>", { desc = "show full buffer path", silent = true } },
	{ "n", "<space>bn", "<cmd>enew<cr>", { desc = "new buffer", silent = true } },
	{ "n", "vig", "ggVG", { desc = "select whole buffer", silent = true } },
}

for _, item in pairs(keymap) do
	vim.api.nvim_set_keymap(table.unpack(item))
end

return module
