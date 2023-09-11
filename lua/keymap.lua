local module = {}
table.unpack = table.unpack or unpack

module.categories = {
	["g"] = { name = "+goto" },
	["]"] = { name = "+next" },
	["["] = { name = "+prev" },
	["<space>l"] = { name = "+list/telescope" },
	["<space>i"] = { name = "+info" },
	["<space>b"] = { name = "+buffers" },
	["<space>w"] = { name = "windows/tabs+" },
	["<leader>d"] = { name = "+debug" },
	["<space>h"] = { name = "+help" },
	["<space>p"] = { name = "+project" },
	["<space>g"] = { name = "+git" },
	["<space>s"] = { name = "+search" },
	["<space>t"] = { name = "+toggles" },
	["<space>u"] = { name = "+ui" },
	["<space>e"] = { name = "+diagnostis" },
	["<space>P"] = { name = "+plugins" },
	["<leader>c"] = { name = "+configuration" },
}

local keymap = {
	-- window management
	{ "n", "<tab>k", "<cmd>wincmd k<cr>", { desc = "move cursor up one window", silent = true } },
	{ "n", "<tab>j", "<cmd>wincmd j<cr>", { desc = "move cursor down one window", silent = true } },
	{ "n", "<tab>h", "<cmd>wincmd h<cr>", { desc = "move cursor left one window", silent = true } },
	{ "n", "<tab>l", "<cmd>wincmd l<cr>", { desc = "move cursor right one window", silent = true } },
	{ "n", "<tab>/", "<cmd>vs<cr>", { desc = "split window vertically", silent = true } },
	{ "n", "<tab>-", "<cmd>sp<cr>", { desc = "split window horizontally", silent = true } },
	{ "n", "<tab>c", "<cmd>close<cr>", { desc = "close current window", silent = true } },
	{ "n", "<tab>d", "<cmd>q<cr>", { desc = "close current window and quit buffer", silent = true } },
	{ "n", "<tab>=", "<C-w>=", { desc = "equalize windows", silent = true } },
	{ "n", "<tab>m", "<C-w>|", { desc = "maximize window", silent = true } },
	{ "n", "<space>w", "<tab>", { desc = "window management", silent = true } },

	-- buffer management
	{ "n", "<space><tab>", "<cmd>b#<cr>", { desc = "previous buffer", silent = true } },
	{ "n", "<space>bd", "<cmd>bdelete!<cr>", { desc = "close current window and quit buffer", silent = true } },

	-- config management
	{
		"n",
		"<leader>cc",
		"<cmd>lua vim.cmd('edit ' .. vim.fn.stdpath('config'))<cr>",
		{ desc = "manage" },
	},

	-- toggles
	{ "n", "<space>ts", "<cmd>let &hls = !&hls<cr>", { desc = "toggle search highlights", silent = true } },
	{ "n", "<space>tr", "<cmd>let &rnu = !&rnu<cr>", { desc = "toggle relative line numbers", silent = true } },
	{ "n", "<space>tn", "<cmd>let &nu = !&nu<cr>", { desc = "toggle line number display", silent = true } },
	{ "n", "<space>tt", "<cmd>let &stal = !&stal<cr>", { desc = "toggle tab display", silent = true } },

	-- layouts/tabs
	{ "n", "<tab>N", "<cmd>tabnew<cr>", { desc = "new tab", silent = true } },
	{ "n", "<tab>1", "1gt", { desc = "go to tab #1", silent = true } },
	{ "n", "<tab>2", "2gt", { desc = "go to tab #2", silent = true } },
	{ "n", "<tab>3", "3gt", { desc = "go to tab #3", silent = true } },
	{ "n", "<tab>4", "4gt", { desc = "go to tab #4", silent = true } },
	{ "n", "<tab>5", "5gt", { desc = "go to tab #5", silent = true } },
	{ "n", "<tab>6", "6gt", { desc = "go to tab #6", silent = true } },
	{ "n", "<tab>7", "7gt", { desc = "go to tab #7", silent = true } },
	{ "n", "<tab>8", "8gt", { desc = "go to tab #8", silent = true } },
	{ "n", "<tab>9", "9gt", { desc = "go to tab #9", silent = true } },

	-- netrw/files
	{ "", "-", "<cmd>execute 'edit ' . expand('%:p%:h')<cr>", { desc = "browse current directory", silent = true } },

	-- help
	{ "n", "<space>hh", "<cmd>lua require('ao.functions').get_help()<cr>", { desc = "show help", silent = true } },

	-- misc
	{ "n", "<space>bp", "1<C-g>:<C-U>echo v:statusmsg<cr>", { desc = "show full buffer path", silent = true } },
	{ "n", "<space>bn", "<cmd>enew<cr>", { desc = "new buffer", silent = true } },
	{ "n", "vig", "ggVG", { desc = "select whole buffer", silent = true } },
	{ "n", "<space>,", ",", { desc = "more options", silent = true } },
}

for _, item in pairs(keymap) do
	vim.api.nvim_set_keymap(table.unpack(item))
end

return module
