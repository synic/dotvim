local keymap = require("ao.keymap")
local proj = require("ao.module.proj")

---@class AIModule
---@field plugins LazySpec[]
local M = {}

M.code_filetypes = {
	"lua",
	"python",
	"javascript",
	"typescript",
	"java",
	"c",
	"cpp",
	"rust",
	"go",
	"php",
	"ruby",
	"sh",
	"bash",
	"vim",
}

local terminals = {}

---@return string
local function get_project_path()
	local root = proj.find_buffer_root()
	return root or vim.fn.getcwd()
end

---@param terminal table The terminal object
---@param text string Text to send to the terminal
local function send_to_terminal(terminal, text)
	if not terminal or not terminal.buf then
		vim.notify("No valid terminal to send text to", vim.log.levels.ERROR)
		return
	end

	if not vim.api.nvim_win_is_valid(terminal.win) then
		vim.notify("Terminal window is invalid", vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_set_current_win(terminal.win)

	vim.schedule(function()
		vim.cmd("startinsert")
		vim.api.nvim_feedkeys(text, "i", true)
	end)
end

---@param terminal table The terminal object
---@param text string The text to send
---@param filetype string|nil The filetype for code formatting
---@param path_with_line string|nil The file path and line number
local function format_and_send_to_terminal(terminal, text, filetype, path_with_line)
	if not terminal then
		return
	end

	terminal:show()

	if filetype and path_with_line then
		local formatted_text = path_with_line .. "\n\n" .. "```" .. filetype .. "\n" .. text .. "\n```\n\n"
		send_to_terminal(terminal, formatted_text)
	else
		send_to_terminal(terminal, text)
	end
end

-- Find .envrc file with ANTHROPIC_API_KEY in the project path or parent directories
---@param path string
---@return string|nil
local function find_envrc_with_api_key(path)
	local current_path = path
	while current_path and current_path ~= "/" do
		local envrc_path = current_path .. "/.envrc"
		local file = io.open(envrc_path, "r")
		if file then
			local content = file:read("*all")
			file:close()

			if content:match("export%s+ANTHROPIC_API_KEY") then
				return envrc_path
			end
		end

		current_path = vim.fn.fnamemodify(current_path, ":h")
	end

	return nil
end

-- Calculate terminal width based on total screen width
---@return number
local function calculate_terminal_width()
	local total_width = vim.o.columns
	local percentage = total_width > 500 and 0.25 or 0.35
	return math.floor(total_width * percentage)
end

-- Build the terminal command for a specific project
---@param project_path string
---@return string
local function build_terminal_cmd(project_path)
	local base_cmd = "cd " .. vim.fn.shellescape(project_path)

	local envrc_path = find_envrc_with_api_key(project_path)
	if envrc_path then
		local display_path = vim.fn.fnamemodify(envrc_path, ":h")
		vim.notify("Using custom Anthropic key for " .. display_path, vim.log.levels.INFO)

		return base_cmd .. " && source " .. vim.fn.shellescape(envrc_path) .. " && claude"
	else
		return base_cmd .. " && claude"
	end
end

-- Get or create a terminal for the current project
---@param force_new? boolean
---@return table|nil # terminal object
local function get_or_create_terminal(force_new)
	local project_path = get_project_path()

	if force_new and terminals[project_path] then
		local terminal = terminals[project_path]
		if terminal and terminal.close then
			terminal:close()
		else
			vim.notify("Unable to close terminal, creating a new one", vim.log.levels.WARN)
		end
		terminals[project_path] = nil
	end

	if not terminals[project_path] then
		local cmd = build_terminal_cmd(project_path)

		-- Create a vertical split on the right side
		vim.cmd("rightbelow vsplit")
		local win = vim.api.nvim_get_current_win()

		-- Resize the window based on total width
		vim.api.nvim_win_set_width(win, calculate_terminal_width())

		-- Start the terminal
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_win_set_buf(win, buf)

		local job_id = vim.fn.jobstart(cmd, { term = true })

		if job_id == 0 or job_id == -1 then
			vim.notify("Failed to start terminal", vim.log.levels.ERROR)
			return nil
		end

		vim.bo[buf].filetype = "ai_terminal"

		-- Create terminal object with necessary methods
		local term_obj = {
			buf = buf,
			win = win,
			job_id = job_id,
			show = function(self)
				if vim.api.nvim_win_is_valid(self.win) then
					vim.api.nvim_set_current_win(self.win)
				else
					-- Window was closed, recreate it
					vim.cmd("rightbelow vsplit")
					self.win = vim.api.nvim_get_current_win()
					vim.api.nvim_win_set_width(self.win, calculate_terminal_width())
					vim.api.nvim_win_set_buf(self.win, self.buf)
				end
			end,
			hide = function(self)
				if vim.api.nvim_win_is_valid(self.win) then
					vim.api.nvim_win_close(self.win, false)
				end
			end,
			is_open = function(self)
				return vim.api.nvim_win_is_valid(self.win)
			end,
			close = function(self)
				-- First kill the job to prevent hanging
				if self.job_id and self.job_id > 0 then
					vim.fn.jobstop(self.job_id)
				end
				if vim.api.nvim_win_is_valid(self.win) then
					vim.api.nvim_win_close(self.win, false)
				end
				if vim.api.nvim_buf_is_valid(self.buf) then
					vim.api.nvim_buf_delete(self.buf, { force = true })
				end
			end,
		}

		vim.keymap.set("t", "<c-g>", function()
			vim.cmd("stopinsert")
		end, { buffer = buf, desc = "Escape to normal mode" })

		vim.keymap.set("n", "q", function()
			term_obj:hide()
		end, { buffer = buf, desc = "Hide terminal" })

		vim.keymap.set("n", "gf", function()
			local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
			if f == "" then
				vim.notify("No file under cursor", vim.log.levels.WARN)
			else
				term_obj:hide()
				vim.schedule(function()
					vim.cmd("e " .. f)
				end)
			end
		end, { buffer = buf, desc = "Open file under cursor" })

		terminals[project_path] = term_obj
		vim.cmd("startinsert")
	end

	return terminals[project_path]
end

-- Toggle the terminal for the current project
function M.toggle_terminal()
	local project_path = get_project_path()

	if terminals[project_path] then
		local terminal = terminals[project_path]
		if terminal:is_open() then
			terminal:hide()
		else
			terminal:show()
		end
	else
		get_or_create_terminal()
	end
end

-- Restart terminal for the current project
function M.restart_terminal()
	get_or_create_terminal(true)
end

-- Kill the terminal for the current project
function M.kill_terminal()
	local project_path = get_project_path()

	if terminals[project_path] then
		local terminal = terminals[project_path]
		terminal:close()
		terminals[project_path] = nil
	end
end

-- Send visual selection to AI terminal
local function send_visual_selection_to_ai(should_toggle)
	vim.cmd('normal! "xy')
	local selection = vim.fn.getreg("x")
	local file_path = vim.fn.expand("%:.")
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local path_with_line = start_line == end_line 
		and file_path .. ":" .. start_line 
		or file_path .. ":" .. start_line .. "-" .. end_line
	local filetype = vim.bo.filetype
	local is_code = vim.tbl_contains(M.code_filetypes, filetype)

	if should_toggle then
		local project_path = get_project_path()
		local terminal_existed = terminals[project_path] ~= nil
		
		M.toggle_terminal()
		
		local terminal = terminals[project_path]
		if not terminal then
			return
		end
		
		local delay = terminal_existed and 100 or 500
		vim.defer_fn(function()
			if is_code then
				format_and_send_to_terminal(terminal, selection, filetype, path_with_line)
			else
				format_and_send_to_terminal(terminal, selection)
			end
		end, delay)
	else
		local terminal = get_or_create_terminal()
		if not terminal then
			return
		end
		
		vim.defer_fn(function()
			if is_code then
				format_and_send_to_terminal(terminal, selection, filetype, path_with_line)
			else
				format_and_send_to_terminal(terminal, selection)
			end
		end, 100)
	end
end

-- Paste visual selection into terminal
function M.paste_visual_selection()
	send_visual_selection_to_ai(false)
end

-- Paste file path and line number into terminal
function M.paste_file_path_line()
	local terminal = get_or_create_terminal()

	if not terminal then
		return
	end

	local file_path = vim.fn.expand("%:.")
	local line_num = vim.fn.line(".")
	local path_with_line = file_path .. ":" .. line_num

	format_and_send_to_terminal(terminal, path_with_line)
end

-- Paste clipboard content into terminal
function M.paste_clipboard()
	local terminal = get_or_create_terminal()

	if not terminal then
		return
	end

	local clipboard = vim.fn.getreg("+")
	if clipboard == "" then
		vim.notify("Clipboard is empty", vim.log.levels.WARN)
		return
	end

	format_and_send_to_terminal(terminal, clipboard)
end

-- Add comma-separated file paths to terminal
function M.add_paths_to_window(paths)
	local terminal = get_or_create_terminal()

	if not terminal then
		return
	end

	terminal:show()

	local paths_text = table.concat(paths, ", ") .. "\n\n"
	send_to_terminal(terminal, paths_text)
end

-- Set up keymaps for the module
function M.setup()
	-- Normal mode mappings for AI terminal operations
	keymap.add({
		{ "<leader>at", M.toggle_terminal, desc = "Toggle AI terminal" },
		{ "<leader>ac", M.restart_terminal, desc = "Clear AI terminal" },
		{ "<leader>aq", M.kill_terminal, desc = "Kill AI terminal" },
		{ "<leader>al", M.paste_file_path_line, desc = "Send file path:line to AI" },
		{ "<leader>ap", M.paste_clipboard, desc = "Paste clipboard to AI" },

		-- Visual mode mapping for sending selected code to Claude
		{
			"<leader>at",
			function()
				send_visual_selection_to_ai(true)
			end,
			desc = "Send selection to AI",
			mode = { "v" },
		},
		{ "<leader>ap", M.paste_visual_selection, desc = "Send selection to AI", mode = { "v" } },

		-- Terminal mode mappings
		{
			"<leader>at",
			function()
				local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
				vim.api.nvim_feedkeys(keys, "n", false)
				M.toggle_terminal()
			end,
			mode = { "t" },
			desc = "Toggle AI terminal in terminal mode",
		},

		-- Shift+Enter for newline in terminal mode
		{ "<S-CR>", "<C-v><CR>", mode = { "t" }, desc = "Insert newline in terminal" },
	})
end

M.plugins = {}

M.setup()

return M
