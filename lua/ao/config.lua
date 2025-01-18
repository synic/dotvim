---@class ProjectConfig
---@field entries table
---@field directory { path: string, skip: string[] }
---@field root_names string[]
---@field bookmarks table
---@field cmd? string

---@class AppearanceConfig
---@field guifont string
---@field theme string

---@class TreesitterConfig
---@field ensure_installed_base string[]
---@field ensure_installed string[]

---@class MasonConfig
---@field ensure_installed_base string[]
---@field ensure_installed string[]

---@class LazyConfig
---@field install { install_missing: boolean }
---@field change_detection { enabled: boolean, notify: boolean }

---@class Config
---@field options { projects: ProjectConfig, appearance: AppearanceConfig, treesitter: TreesitterConfig, mason: MasonConfig, lazy: LazyConfig }

vim.o.shada = "!,'20,<50,s10,h"
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab| ")
vim.g.neovide_remember_window_size = true
vim.o.winblend = 10

-- Create the autocmd group and command
---@type integer
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.notify("Type <C-g> to exit terminal input mode")
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

---@type Config
return {
	options = {
		projects = {
			entries = {},
			directory = { path = os.getenv("HOME") .. "/Projects", skip = {} },
			root_names = { ".git", ".svn", ".project_root", "mix.exs" },
			-- example command to list and sort by mtime on macos with coreutils:
			-- cmd = 'find /Users/synic/Projects ! -name ".*" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 ls -1 -td',
			bookmarks = {},
		},

		appearance = {
			guifont = "Hack Nerd Font Mono:h12",
			theme = "gruvbox-material",
		},

		treesitter = {
			ensure_installed_base = { "lua", "vimdoc" },
			ensure_installed = {},
		},

		mason = {
			ensure_installed_base = { "lua_ls", "vimls", "bashls" },
			ensure_installed = {},
		},

		lazy = {
			install = { install_missing = false },
			change_detection = {
				-- with change detection enabled, lazy.nvim does something when you save
				-- lua files that are modules. whatever it does, it wipes out the none-ls
				-- autocmd that is set up to format on save. It also causes other events to
				-- attach more than once (gitsigns). better to just leave it off.
				enabled = false,
				notify = false,
			},
		},
	},
}
