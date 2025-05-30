---@alias KeymapOpts { buffer?: boolean|integer, desc?: string, expr?: boolean, modes?: string[], silent?: boolean, test?: boolean }
---@alias Keymap { [1]: string, [2]: string|function, desc?: string, buffer?: boolean, expr?: boolean, mode?: string[], silent?: boolean, test?: boolean|number }
---
local get_help
local M = {}

--- Basic Keymaps
---
--- Plugin specific keymaps are defined on their plugin spec

---@type WhichKey.Spec
---@diagnostic disable-next-line: missing-fields
M.categories = {
	{ "<leader>a", group = "ai" },
	{ "<leader>b", group = "buffers" },
	{ "<leader>c", group = "configuration" },
	{ "<leader>cp", group = "plugins" },
	{ "<leader>cP", group = "lazy" },
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
	{ "<leader>ws", group = "session" },
	{ "<leader>x", group = "misc" },
	{ ";", group = "hop" },
	{ "<localleader>t", group = "neotest" },
	{ "gh", group = "hunk" },

	-- Visual mode categories
	{ "<leader>a", mode = "v", group = "ai" },
	{ "<leader>x", mode = "v", group = "misc" },
}

M.setup_basic_keymap = function()
	M.add({
		-- windows
		{ "<leader>wk", "<cmd>wincmd k<cr>", desc = "Go up" },
		{ "<leader>wj", "<cmd>wincmd j<cr>", desc = "Go down" },
		{ "<leader>wh", "<cmd>wincmd h<cr>", desc = "Go left" },
		{ "<leader>wl", "<cmd>wincmd l<cr>", desc = "Go right" },
		-- terminal mode window navigation
		{ "<leader>wk", "<C-\\><C-n><cmd>wincmd k<cr>", mode = { "t" }, desc = "Go up from terminal" },
		{ "<leader>wj", "<C-\\><C-n><cmd>wincmd j<cr>", mode = { "t" }, desc = "Go down from terminal" },
		{ "<leader>wh", "<C-\\><C-n><cmd>wincmd h<cr>", mode = { "t" }, desc = "Go left from terminal" },
		{ "<leader>wl", "<C-\\><C-n><cmd>wincmd l<cr>", mode = { "t" }, desc = "Go right from terminal" },
		{ "<leader>w/", "<cmd>vs<cr>", desc = "Split vertically" },
		{ "<leader>w-", "<cmd>sp<cr>", desc = "Split horizontally" },
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
		{
			"<leader>w;",
			require("ao.module.ui").zero_window_cursors,
			desc = "Move cursor to 0 in all but the current window",
		},
		{ "<leader>w;", require("ao.module.ui").zero_all_window_cursors, desc = "Move cursor to 0 in all windows" },
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
		{ "<leader>ln", "<cmd>tabnew<cr><cmd>set showtabline=1<cr>", desc = "New layout" },
		{ "<leader>l1", "1gt", desc = "Go to layout #1" },
		{ "<leader>l2", "2gt", desc = "Go to layout #2" },
		{ "<leader>l3", "3gt", desc = "Go to layout #3" },
		{ "<leader>l4", "4gt", desc = "Go to layout #4" },
		{ "<leader>l5", "5gt", desc = "Go to layout #5" },
		{ "<leader>l6", "6gt", desc = "Go to layout #6" },
		{ "<leader>l7", "7gt", desc = "Go to layout #7" },
		{ "<leader>l8", "8gt", desc = "Go to layout #8" },
		{ "<leader>l9", "9gt", desc = "Go to layout #9" },
		{ "<c-1>", "1gt", desc = "Go to layout #1" },
		{ "<c-2>", "2gt", desc = "Go to layout #2" },
		{ "<c-3>", "3gt", desc = "Go to layout #3" },
		{ "<c-4>", "4gt", desc = "Go to layout #4" },
		{ "<c-5>", "5gt", desc = "Go to layout #5" },
		{ "<c-6>", "6gt", desc = "Go to layout #6" },
		{ "<c-7>", "7gt", desc = "Go to layout #7" },
		{ "<c-8>", "8gt", desc = "Go to layout #8" },
		{ "<c-9>", "9gt", desc = "Go to layout #9" },
		{ "<leader>lc", "<cmd>tabclose<cr>", desc = "Close layout" },
		{ "<leader>lj", "<cmd>tabnext<cr>", desc = "Next layout" },
		{ "<leader>lk", "<cmd>tabprev<cr>", desc = "Previous layout" },
		{ "<leader>l<tab>", "g<Tab>", desc = "Go to last layout" },
		{ "<leader>lN", require("ao.module.layout").set_name, desc = "Set layout name" },
		{ "<leader>ll", require("ao.module.layout").pick, desc = "List layouts" },

		-- toggles
		{ "<leader>th", "<cmd>let &hls = !&hls<cr>", desc = "Toggle search highlights" },
		{ "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "Toggle relative line numbers" },
		{ "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "Toggle line number display" },
		{ "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "Toggle tab display" },
		{ "<leader>tc", "<cmd>let &cuc = !&cuc<cr>", desc = "Toggle cursor column display" },
		{ "<leader>ti", "<cmd>lua vim.opt.list = not vim.opt.list:get()<cr>", desc = "Toggle indent guide" },
		{ "<leader>tw", "<cmd>let &wrap = !&wrap<cr>", desc = "Toggle wrap" },
		{
			"<leader>ta",
			function()
				vim.diagnostic.enable(not vim.diagnostic.is_enabled())
			end,
			desc = "LSP diagnostics",
		},

		-- buffers
		{ "<leader><tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
		{ "<leader>b<tab>", "<cmd>b#<cr>", desc = "Previous buffer" },
		{ "<leader>bd", "<cmd>bdelete!<cr>", desc = "Close current window and quit buffer" },
		{ "<leader>bp", require("ao.module.ui").buffer_copy_path, desc = "Copy buffer path" },
		{ "<leader>bP", require("ao.module.ui").buffer_copy_full_path, desc = "Copy full buffer path" },
		{
			"<leader>bl",
			require("ao.module.ui").buffer_copy_path_and_line,
			desc = "Copy path with line number",
		},
		{ "<leader>bn", "<cmd>enew<cr>", desc = "New buffer" },

		-- help
		{ "<leader>hh", get_help, desc = "Show help" },
		{ "<leader>hc", "<cmd>execute 'help ' .. expand('<cword>')<cr>", desc = "Help for word under cursor" },
		{ "<leader>?", get_help, desc = "Show help" },

		-- quickfix
		{ "<leader>qq", "<cmd>copen<cr>", desc = "Open quickfix" }, -- overridden in trouble.nvim
		{ "<leader>qj", "<cmd>cn<cr>", desc = "Next quickfix item" },
		{ "<leader>qk", "<cmd>cp<cr>", desc = "Previous quickfix item" },
		{ "<leader>qn", "<cmd>cn<cr>", desc = "Next quickfix item" },
		{ "<leader>qp", "<cmd>cp<cr>", desc = "Previous quickfix item" }, -- overridden in trouble.nvim
		{ "<leader>qc", "<cmd>cclose<cr>", desc = "Close quickfix" },
		{
			"<leader>q<space>",
			require("ao.module.ui").quickfix_remove_item_move_next,
			desc = "Remove quickfix item and move next",
		},

		-- better movement
		{ "j", "v:count == 0 ? 'gj' : 'j'", mode = { "n", "x" }, desc = "Down", expr = true, silent = true },
		{ "<Down>", "v:count == 0 ? 'gj' : 'j'", mode = { "n", "x" }, desc = "Down", expr = true, silent = true },
		{ "k", "v:count == 0 ? 'gk' : 'k'", mode = { "n", "x" }, desc = "Up", expr = true, silent = true },
		{ "<Up>", "v:count == 0 ? 'gk' : 'k'", mode = { "n", "x" }, desc = "Up", expr = true, silent = true },

		-- configuration
		{ "<leader>cm", require("ao.module.fs").goto_config_directory, desc = "Manage config" },
		{ "<leader>cl", require("ao.module.ui").goto_lazy_dir, desc = "Go to lazy plugins dir" },
		{ "<leader>cd", require("ao.module.ui").goto_dotfiles_dir, desc = "Go to dotfiles directory" },

		-- copy/paste on mac
		{ "<D-v>", "+p<CR>", mode = { "" }, noremap = true, silent = true, test = vim.fn.has("macunix") },
		{ "<D-v>", "<C-R>+", mode = { "!", "t", "v" }, noremap = true, silent = true, test = vim.fn.has("macunix") },

		-- change the default key to start recording a macro from `q` to `Q`
		{ "q", "<nop>", desc = "Disable macro recording with q" },
		{ "Q", "q", desc = "Start macro recording" },

		-- misc
		{ "vig", "ggVG", desc = "Select whole buffer" },
		{ "<leader>xq", "<cmd>qa!<cr>", desc = "Quit Vim" },
		{ "<leader>xx", require("ao.module.ui").close_all_floating_windows, desc = "Close all floating windows" },
		{ "<leader>'", "<cmd>split<cr><cmd>term<cr><cmd>norm A<cr>", desc = "Open terminal" },
		{
			"<c-g>",
			function()
				local keys = vim.api.nvim_replace_termcodes("<C-g>", true, true, true)
				vim.api.nvim_feedkeys(keys, "nx", false)
				local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
				vim.fn.setreg("+", filepath)
			end,
			mode = { "n" },
			desc = "Show buffer information and copy filepath",
		},
	})
end

---@return nil
function get_help()
	---@diagnostic disable-next-line: missing-fields
	vim.ui.input({ prompt = "enter search term" }, function(input)
		if input == nil then
			return
		end
		vim.cmd("help " .. input)
	end)
end

---@param keymap Keymap[]
---@return nil
function M.add(keymap)
	for _, key_data in ipairs(keymap) do
		local mode = key_data.mode or { "n" }
		local should_apply = true

		if key_data.test ~= nil then
			should_apply = key_data.test ~= 0 and key_data.test ~= nil
			key_data.test = nil
		end

		key_data.mode = nil

		if should_apply then
			local left = key_data[1]
			local right = key_data[2]

			if right == nil then
				print("ERROR: nil keymap for key: " .. tostring(left))
				print("Key data:", vim.inspect(key_data))
			end

			key_data[1] = nil
			key_data[2] = nil

			for _, m in ipairs(mode) do
				vim.keymap.set(m, left, right, key_data)
			end
		end
	end
end

return M
