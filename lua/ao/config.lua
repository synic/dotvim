vim.o.shada = "!,'20,<50,s10,h"
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab| ")
vim.g.neovide_remember_window_size = true

return {
	options = {
		projects = {
			directory = os.getenv("HOME") .. "/Projects",
			root_names = { ".git", ".svn", ".project_root" },
			-- example command to list and sort by mtime on macos with coreutils:
			-- cmd = 'find /Users/synic/Projects ! -name ".*" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 ls -1 -td',
			bookmarks = {},
		},

		appearance = {
			guifont = "Hack:h11",
			theme = "duskfox",
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
		default_cololorschemes = {},
	},
}
