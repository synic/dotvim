local keymap = require("ao.keymap")

---@type PluginModule
local M = {}

local function git_add()
	vim.cmd("silent !git add %")
	vim.notify("Issued `git add " .. vim.fn.expand("%p") .. "` ...")
end

local function show_git_branch()
	local branch = M.git_get_current_branch()
	if not branch or branch == "" then
		branch = "not currently in a repository"
	else
		vim.fn.setreg("+", branch)
	end

	vim.notify("Branch: " .. branch)
	print(branch)
end

keymap.add({
	{ "<leader>g?", show_git_branch, desc = "Show current branch" },
})

function M.git_get_repo_name()
	local out = io.popen("git rev-parse --show-toplevel")
	if out then
		local name = out:read("*l")
		out:close()

		if name then
			return vim.fs.base(name)
		end
	end
	return nil
end

function M.git_get_current_branch()
	local out = io.popen("git rev-parse --abbrev-ref HEAD 2> /dev/null")
	if out then
		local name = out:read("*l")
		out:close()
		if name then
			return name
		end
	end
	return nil
end

local function gitsigns_on_attach(bufnr)
	local gs = package.loaded.gitsigns

	keymap.add({
		{ "]h", gs.next_hunk, desc = "Next hunk", buffer = bufnr },
		{ "[h", gs.prev_hunk, desc = "Prev hunk", buffer = bufnr },
		{
			"ghs",
			"<cmd>Gitsigns stage_hunk<CR>",
			desc = "Stage hunk",
			buffer = bufnr,
			mode = { "n", "v" },
		},
		{
			"ghr",
			"<cmd>Gitsigns reset_hunk<CR>",
			desc = "Reset hunk",
			buffer = bufnr,
			mode = { "n", "v" },
		},
		{ "ghS", gs.stage_buffer, desc = "Stage buffer", buffer = bufnr },
		{ "ghu", gs.undo_stage_hunk, desc = "Undo stage Hunk", buffer = bufnr },
		{ "ghR", gs.reset_buffer, desc = "Reset buffer", buffer = bufnr },
		{ "ghp", gs.preview_hunk, desc = "Preview hunk", buffer = bufnr },
		{
			"ghb",
			function()
				gs.blame_line({ full = true })
			end,
			desc = "Blame line",
			buffer = bufnr,
		},
		{ "ghd", gs.diffthis, desc = "Diff this", buffer = bufnr },
		{
			"ghD",
			function()
				gs.diffthis("~")
			end,
			desc = "Diff this ~",
			buffer = bufnr,
		},
		{
			"ih",
			"<cmd><C-U>Gitsigns select_hunk<cr>",
			desc = "Select hunk",
			buffer = bufnr,
			mode = { "o", "x" },
		},
	})
end

-- Open Neogit
--
-- This function goes through all the buffers and closes any that are the neogit status buffer, and _then_ opens
-- Neogit. This is because if you open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. Neogit is already open, even if you can't see it.
local function neogit_open()
	local neogit = require("neogit")
	local root = vim.fs.root(0, { ".git" })

	if not root then
		vim.notify("Could not determine git root", vim.log.levels.WARN)
		return
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype:find("^Neogit") ~= nil then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	neogit.open({ cwd = root })
end

-- Open GitBlame
--
-- This function goes through all open buffers, closes any existing gitsigns-blame windows (removing their WinClosed
-- events first), and then opens a new blame window. It also attaches an event to the new blame window to make it so
-- that when blame is closed (either through toggle or through `q`), it puts the cursor back in the window that opened
-- the blame, instead of just focusing whatever window is on the left of the blame.
local function open_gitblame()
	local current_win = vim.fn.win_getid()

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "gitsigns-blame" then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == buf then
					vim.api.nvim_clear_autocmds({
						event = "WinClosed",
						pattern = tostring(win),
					})
					vim.api.nvim_win_close(win, true)
				end
			end
		end
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "gitsigns-blame",
		callback = function()
			vim.api.nvim_create_autocmd("WinClosed", {
				pattern = tostring(vim.fn.win_getid()),
				callback = function()
					pcall(vim.api.nvim_set_current_win, current_win)
				end,
				once = true,
			})
		end,
		once = true,
	})
	vim.cmd.Gitsigns("blame")
end

M.plugins = {
	-- display conflicts
	{ "akinsho/git-conflict.nvim", event = "VeryLazy", version = "*", config = true },

	-- show git status in gutter, allow staging of hunks
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
			{ "<leader>gB", open_gitblame, desc = "Git blame file" },
		},
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = gitsigns_on_attach,
		},
	},

	-- git client
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		keys = {
			{ "<leader>gs", neogit_open, desc = "Git status" },
		},
		opts = {
			kind = "vsplit",
			auto_show_console = false,
			remember_settings = true,
			commit_editor = { kind = "split" },
			commit_select_view = { kind = "split" },
			log_view = { kind = "split" },
			rebase_editor = { kind = "split" },
			reflog_view = { kind = "split" },
			merge_editor = { kind = "split" },
			description_editor = { kind = "split" },
			tag_editor = { kind = "split" },
			preview_buffer = { kind = "split" },
			popup = { kind = "split" },
			auto_refresh = true,
			filewatcher = {
				interval = 1000,
				enabled = true,
			},
			commit_view = {
				kind = "vsplit",
				verify_commit = vim.fn.executable("gpg") == 1,
			},
		},
	},
}

keymap.add({
	{ "<leader>ga", git_add, desc = "Git add" },
})

return M
