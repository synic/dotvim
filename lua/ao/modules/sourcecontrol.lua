local utils = require("ao.utils")
local projects = require("ao.modules.projects")
local M = {}

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

utils.map_keys({
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

	utils.map_keys({
		{ "]h", gs.next_hunk, desc = "Next hunk", buffer = bufnr },
		{ "[h", gs.prev_hunk, desc = "Prev hunk", buffer = bufnr },
		{
			"ghs",
			"<cmd>Gitsigns stage_hunk<CR>",
			desc = "Stage hunk",
			buffer = bufnr,
			modes = { "n", "v" },
		},
		{
			"ghr",
			"<cmd>Gitsigns reset_hunk<CR>",
			desc = "Reset hunk",
			buffer = bufnr,
			modes = { "n", "v" },
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
			modes = { "o", "x" },
		},
	})
end

-- Open NeoGit
--
-- This function goes through all the buffers and closes any that are
-- the neogit status buffer, and _then_ opens NeoGit. This is because if you
-- open neogit on one tab, and leave it open, and then try to open neogit again on
-- another tab, nothing will happen. NeoGit is already open, even if you can't see it.
local function neogit_open()
	local neogit = require("neogit")
	local root = projects.find_buffer_root()
	local cwd = (utils.get_buffer_cwd() or ".")

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype:find("^Neogit") ~= nil then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	cwd = (root or cwd)

	neogit.open({ cwd = cwd })
end

M.plugin_specs = {
	-- display conflicts
	{ "akinsho/git-conflict.nvim", event = "VeryLazy", version = "*", config = true },

	-- git utilities
	{
		"FabijanZulj/blame.nvim",
		lazy = false,
		opts = {
			date_format = "%Y.%m.%d %H:%M",
		},
		keys = {
			{ "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Git blame" },
		},
	},

	-- show git status in gutter, allow staging of hunks
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
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

return M
