---@class ProjectConfig
---@field entries table
---@field directory { path: string, skip: string[] }
---@field root_names string[]
---@field bookmarks table
---@field cmd? string

---@class AppearanceConfig
---@field font string|nil
---@field theme string|nil

---@class LazyConfig
---@field install { install_missing: boolean }
---@field change_detection { enabled: boolean, notify: boolean }

---@class Config
---@field options { projects: ProjectConfig, appearance: AppearanceConfig, languages: string[], extra_languages: string[], lazy: LazyConfig }

vim.o.shada = "!,'20,<50,s10,h"
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab| ")
vim.o.winblend = 10
vim.o.winborder = "single"
vim.o.undofile = true

if vim.fn.has("nvim-0.11") then
	vim.o.numberwidth = 3
	vim.o.signcolumn = "yes:1"
	vim.o.statuscolumn = "%s%l "

	-- disable deprecation warnings for now, tons of plugins are not ready for this update yet, and none of my code is
	-- deprecated.
	---@diagnostic disable-next-line: duplicate-set-field
	vim.deprecate = function() end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.cmd("wincmd J")
	end,
})

-- Create the autocmd group and command
---@type integer
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"

		require("ao.keymap").add({
			{
				"<S-CR>",
				function()
					vim.api.nvim_feedkeys("\n", "t", false)
				end,
				desc = "Send newline",
				mode = { "t" },
			},
		})
	end,
})

---@type Config
return {
	options = {
		projects = {
			entries = {},
			directory = { path = os.getenv("HOME") .. "/Projects", skip = {} },
			root_names = { ".git", ".svn", ".project_root", "mix.exs", "package.json" },
			-- example command to list and sort by mtime on macos with coreutils:
			-- cmd = 'find /Users/synic/Projects ! -name ".*" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 ls -1 -td',
			bookmarks = {},
		},

		appearance = {
			font = nil, -- "Hack Nerd Font:h12",
			theme = "gruvbox-material",
		},

		languages = { "lua", "vim", "bash", "markdown", "git", "json" },
		extra_languages = {},

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
