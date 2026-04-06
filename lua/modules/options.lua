local M = {}

function M.setup()
	vim.g.mapleader = " "
	vim.g.maplocalleader = ","

	local opt = vim.opt

	opt.backspace = "2"
	opt.smartindent = true
	opt.autoindent = true
	opt.backup = false
	opt.history = 50
	opt.ruler = true
	opt.wrap = false
	opt.splitright = true
	opt.splitbelow = true
	opt.visualbell = true
	opt.incsearch = true
	opt.wildmenu = true
	opt.wildmode = "longest:full,full"
	opt.hlsearch = false
	opt.equalalways = true
	opt.writebackup = false
	opt.backup = false
	opt.swapfile = false
	opt.autoread = true
	opt.laststatus = 2
	opt.cursorbind = false
	opt.scrollbind = false
	opt.hidden = true
	opt.completeopt = { "menu", "menuone", "noselect" }
	opt.shortmess:append("I")
	opt.encoding = "utf-8"
	opt.scrolloff = 15
	opt.cursorline = true
	opt.listchars = { tab = "| ", eol = "↵" }
	opt.statusline = "%<%n:%f%h%m%r%= %{&ff} %l,%c%V %P"
	opt.mousehide = true
	opt.mousefocus = false
	opt.mousemodel = "extend"
	opt.mouse = "a"
	opt.modeline = true
	opt.modelines = 5
	opt.showmatch = true
	opt.matchtime = 5
	opt.ignorecase = true
	opt.smartcase = true
	opt.tabstop = 4
	opt.shiftwidth = 4
	opt.softtabstop = 4
	opt.shiftround = true
	opt.expandtab = true
	opt.textwidth = 78
	opt.formatoptions:append("t")
	opt.colorcolumn = "0"
	opt.number = true
	opt.showtabline = 1
	opt.exrc = true
	opt.secure = true
	opt.clipboard = "unnamed"
	opt.termguicolors = true
	vim.o.timeout = true
	vim.o.timeoutlen = 500

	-- swap directory
	local vimhome = vim.fn.stdpath("config")
	local swapdir = vimhome .. "/swap"
	vim.fn.mkdir(swapdir, "p")
	opt.dir = swapdir

	-- Keymaps
	local map = vim.keymap.set

	map("v", "<", "<gv")
	map("v", ">", ">gv")
	map("n", "vig", "ggVG")
	map("n", "yig", "ggVGy")

	-- enable putting without yanking
	map("x", "p", function()
		return 'pgv"' .. vim.v.register .. "y`>"
	end, { expr = true })

	-- automatically check if files have changed
	local autoreload = vim.api.nvim_create_augroup("AutoReload", { clear = true })
	vim.api.nvim_create_autocmd("CursorHold", {
		group = autoreload,
		callback = function()
			if vim.fn.getcmdwintype() == "" then
				vim.cmd("checktime")
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
		group = autoreload,
		callback = function()
			if vim.fn.getcmdwintype() == "" then
				vim.cmd("checktime")
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "FocusLost", "WinLeave" }, {
		group = autoreload,
		callback = function()
			if vim.fn.getcmdwintype() == "" then
				vim.cmd("checktime")
			end
		end,
	})

	-- set LC_CTYPE on mac if not already set
	if vim.fn.has("macunix") == 1 and vim.env.LC_CTYPE == nil then
		vim.env.LC_CTYPE = "en_US.UTF-8"
	end
end

return M
