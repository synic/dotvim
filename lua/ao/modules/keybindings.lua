local utils = require("ao.utils")
local filesystem = require("ao.modules.filesystem")
local interface = require("ao.modules.interface")

local key_categories = {
	{ "<leader>-", group = "split" },
	{ "<leader>/", group = "vsplit" },
	{ "<leader>a", group = "ai" },
	{ "<leader>b", group = "buffers" },
	{ "<leader>c", group = "configuration" },
	{ "<leader>cp", group = "plugins" },
	{ "<leader>d", group = "debug" },
	{ "<leader>dt", group = "testing" },
	{ "<leader>e", group = "diagnostis" },
	{ "<leader>f", group = "files" },
	{ "<leader>g", group = "git" },
	{ "<leader>gp", group = "pr" },
	{ "<leader>h", group = "help" },
	{ "<leader>l", group = "layouts" },
	{ "<leader>p", group = "project" },
	{ "<leader>q", group = "quickfix" },
	{ "<leader>s", group = "search" },
	{ "<leader>t", group = "toggles" },
	{ "<leader>w", group = "windows" },
	{ "<leader>wm", group = "move" },
	{ "<leader>x", group = "misc" },
	{ ";", group = "hop" },
	{ "<localleader>t", group = "neotest" },
	{ "gh", group = "hunk" },

	-- Visual mode categories
	{ "<leader>a", mode = "v", group = "ai" },
	{ "<leader>x", mode = "v", group = "misc" },
}

utils.map_keys({
	-- windows
	{ "<leader>wk", "<cmd>wincmd k<cr>", desc = "Go up" },
	{ "<leader>wj", "<cmd>wincmd j<cr>", desc = "Go down" },
	{ "<leader>wh", "<cmd>wincmd h<cr>", desc = "Go left" },
	{ "<leader>wl", "<cmd>wincmd l<cr>", desc = "Go right" },
	{ "<leader>w/", "<cmd>vs<cr>", desc = "Split vertically" },
	{ "<leader>w-", "<cmd>sp<cr>", desc = "Split horizontally" },
	{ "<leader>/w", "<cmd>vs<cr>", desc = "Split window vertically" },
	{ "<leader>-w", "<cmd>sp<cr>", desc = "Split window horizontally" },
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
	{ "<leader>w;", interface.zero_window_cursors, desc = "Move cursor to 0 in all but the current window" },
	{ "<leader>w;", interface.zero_all_window_cursors, desc = "Move cursor to 0 in all windows" },
	{ "<leader>w1", "<cmd>1windo norm! m'<cr>", desc = "Goto window #1" },
	{ "<leader>w2", "<cmd>2windo norm! m'<cr>", desc = "Goto window #2" },
	{ "<leader>w3", "<cmd>3windo norm! m'<cr>", desc = "Goto window #3" },
	{ "<leader>w4", "<cmd>4windo norm! m'<cr>", desc = "Goto window #4" },
	{ "<leader>w5", "<cmd>5windo norm! m'<cr>", desc = "Goto window #5" },
	{ "<leader>w6", "<cmd>6windo norm! m'<cr>", desc = "Goto window #6" },
	{ "<leader>w7", "<cmd>7windo norm! m'<cr>", desc = "Goto window #7" },
	{ "<leader>w8", "<cmd>8windo norm! m'<cr>", desc = "Goto window #8" },
	{ "<leader>w9", "<cmd>9windo norm! m'<cr>", desc = "Goto window #9" },

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
	{ "<leader>lN", interface.layout_set_name, desc = "Set layout name" },

	-- toggles
	{ "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "Toggle search highlights" },
	{ "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "Toggle relative line numbers" },
	{ "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "Toggle line number display" },
	{ "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "Toggle tab display" },
	{ "<leader>tc", "<cmd>let &cuc = !&cuc<cr>", desc = "Toggle cursor column display" },
	{ "<leader>ti", "<cmd>lua vim.opt.list = not vim.opt.list:get()<cr>", desc = "Toggle indent guide" },
	{ "<leader>tw", "<cmd>lua vim.opt.list = not vim.opt.list:get()<cr>", desc = "Toggle indent guide" },

	-- buffers
	{ "<leader><tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
	{ "<leader>b<tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
	{ "<leader>bd", "<cmd>bdelete!<cr>", desc = "Close current window and quit buffer" },
	{ "<leader>bp", interface.buffer_show_path, desc = "Show buffer path" },
	{ "<leader>bP", interface.buffer_show_full_path, desc = "Show full buffer path" },
	{ "<leader>bn", "<cmd>enew<cr>", desc = "New buffer" },

	-- help
	{ "<leader>hh", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },
	{ "<leader>?", "<cmd>lua require('ao.utils').get_help()<cr>", desc = "Show help" },

	-- quickfix
	{ "<leader>qq", "<cmd>copen<cr>", desc = "Open quickfix" }, -- overridden in trouble.nvim
	{ "<leader>qj", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>qk", "<cmd>cp<cr>", desc = "Previous quickfix item" },
	{ "<leader>qn", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>qp", "<cmd>cp<cr>", desc = "Previous quickfix item" }, -- overridden in trouble.nvim
	{ "<leader>qc", "<cmd>cclose<cr>", desc = "Close quickfix" },
	{ "g;", "<cmd>cn<cr>", desc = "Next quickfix item" },
	{ "<leader>q<space>", interface.quickfix_remove_item_move_next, desc = "Remove quickfix item and move next" },

	-- configuration
	{ "<leader>cm", filesystem.goto_config_directory, desc = "Manage config" },
	{ "<leader>cl", interface.goto_lazy_dir, desc = "Go to lazy plugins dir" },
	{ "<leader>cd", interface.goto_dotfiles_dir, desc = "Go to dotfiles directory" },

	-- copy/paste on mac
	{ "<D-v>", "+p<CR>", modes = { "" }, noremap = true, silent = true, test = vim.fn.has("macunix") },
	{ "<D-v>", "<C-R>+", modes = { "!", "t", "v" }, noremap = true, silent = true, test = vim.fn.has("macunix") },

	-- change the default key to start recording a macro from `q` to `Q`
	{ "q", "<nop>", desc = "Disable macro recording with q" },
	{ "Q", "q", desc = "Start macro recording" },

	-- misc
	{ "vig", "ggVG", desc = "Select whole buffer" },
	{ "<leader><localleader>", "<localleader>", desc = "Local buffer options" },
	{ "<leader>xq", "<cmd>qa!<cr>", desc = "Quit Vim" },
	{ "<leader>xx", utils.close_all_floating_windows, desc = "Close all floating windows" },
	{ "<leader>'", "<cmd>split<cr><cmd>term<cr><cmd>norm A<cr>", desc = "Open terminal" },
	{ "<C-g>", "<C-\\><C-n>", modes = { "t" }, desc = "Exit terminal mode" },
})

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 700
		end,
		opts = {
			preset = "modern",
			plugins = { spelling = true },
			icons = { mappings = false },
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add(key_categories)
		end,
	},
}
