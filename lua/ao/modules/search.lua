local projects = require("ao.modules.projects")

local function setup_ctrlsf_syntax()
	-- Define syntax matches for the CtrlSF window
	vim.cmd([[
    function! g:CtrlSFSyntax()
      " Clear existing syntax definitions
      syntax clear

      " Match file paths
      syntax match CtrlSFPath       /^.\{-}\ze\[\d\+\]\=/

      " Match line numbers
      syntax match CtrlSFLineNr     /\[\d\+\]/

      " Match search pattern
      syntax match CtrlSFSearchPattern /\v<%(pattern)>/

      " Match matches in preview
      syntax match CtrlSFMatch      /\v\c<%(pattern)>/

      " Define highlight groups
      highlight default link CtrlSFPath       Directory
      highlight default link CtrlSFLineNr     LineNr
      highlight default link CtrlSFMatch      Search
      highlight default link CtrlSFSearchPattern Search
    endfunction

    " Apply syntax when opening CtrlSF window
    augroup CtrlSFSyntax
      autocmd!
      autocmd FileType ctrlsf call g:CtrlSFSyntax()
    augroup END
  ]])
end

local function search_in_project_root()
	local root = projects.find_buffer_root()
	vim.ui.input({ prompt = "term: " }, function(input)
		vim.cmd('CtrlSF "' .. input .. '"')
		vim.cmd("CtrlSF " .. input .. " " .. root)
	end)
end

local function ctrlsf_search_project_cursor_term()
	local root = projects.find_buffer_root()
	local current_word = vim.fn.expand("<cword>")
	vim.cmd("CtrlSF " .. current_word .. " " .. root)
end

-- Function to update the search pattern highlighting
--
---@diagnostic disable-next-line: unused-function, unused-local
local function update_ctrlsf_pattern(pattern)
	if pattern and pattern ~= "" then
		vim.cmd(string.format(
			[[
      syntax clear CtrlSFMatch CtrlSFSearchPattern
      syntax match CtrlSFMatch      /\v\c<%s>/
      syntax match CtrlSFSearchPattern /\v<%s>/
    ]],
			pattern,
			pattern
		))
	end
end

-- Set up CtrlSF options
local function setup_ctrlsf()
	-- Basic CtrlSF configurations
	vim.g.ctrlsf_backend = "rg"
	vim.g.ctrlsf_auto_preview = 1
	vim.g.ctrlsf_case_sensitive = "smart"
	vim.g.ctrlsf_default_view_mode = "compact"
	vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
	vim.g.ctrlsf_default_view_mode = "normal"
	vim.g.ctrlsf_default_root = "project+wf"
	vim.g.ctrlsf_auto_close = { normal = 0, compact = 1 }
	vim.g.ctrlsf_auto_focus = { at = "start" }

	-- Set up syntax highlighting
	setup_ctrlsf_syntax()

	-- Create autocmd to update pattern whenever search is performed
	vim.cmd([[
    augroup CtrlSFUpdatePattern
      autocmd!
      autocmd User CtrlSFAfterSearch lua update_ctrlsf_pattern(vim.fn.getreg('/'))
    augroup END
  ]])
end

return {
	{
		"dyng/ctrlsf.vim",
		cmd = { "CtrlSF" },
		keys = {

			{ "<leader>s/", search_in_project_root, desc = "Search in project root" },
			{
				"<leader>s*",
				ctrlsf_search_project_cursor_term,
				desc = "Search project for term in CtrlSF",
				mode = { "n", "v" },
			},
		},
		config = function(_, _)
			setup_ctrlsf()
		end,
		init = function()
			vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
			vim.g.ctrlsf_default_view_mode = "normal"
			vim.g.ctrlsf_default_root = "project+wf"
			vim.g.ctrlsf_auto_close = {
				normal = 0,
				compact = 1,
			}
			vim.g.ctrlsf_auto_focus = {
				at = "start",
			}
		end,
	},
}
