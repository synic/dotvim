local m = {}

function m.telescope_search_star()
	local builtin = require("telescope.builtin")
	local current_word = vim.fn.expand("<cword>")
	local project_dir = vim.fn.ProjectRootGuess()
	builtin.grep_string({
		cwd = project_dir,
		search = current_word,
	})
end

function m.telescope_search_cwd()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

function m.telescope_search_for_term(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	local prompt = current_picker:_get_prompt()
	vim.cmd(":CtrlSF " .. prompt)
end

function m.telescope_load_projects()
	require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
end

function m.telescope_new_tab_with_projects()
	vim.cmd(":tabnew<cr>")
	m.telescope_load_projects()
end

function m.neotree_project_root()
	local project_dir = vim.fn.ProjectRootGuess()
	vim.cmd(":Neotree " .. project_dir)
end

return m
