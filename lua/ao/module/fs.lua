local proj = require("ao.module.proj")

local oil_setup_keys_group = vim.api.nvim_create_augroup("OilSetupKeys", { clear = true })

---@type PluginModule
local M = {}

M.browse_directory = function(type, precmd)
	return function()
		if precmd then
			vim.cmd[precmd]()
		end

		if type == "current" then
			-- oil is a bit strange, if you pass no arguments, it does not open in `vim.uv.cwd()` like telescope. It always
			-- opens in the current buffer's directory. If you pass a path, it won't select the current buffer's file
			-- automatically.
			vim.cmd.Oil()
		else
			local pathname = proj.find_buffer_root()
			vim.cmd.Oil((pathname or "."))
		end
	end
end

local function oil_rename()
	local oil = require("oil")
	local entry = oil.get_cursor_entry()

	if entry ~= nil then
		vim.ui.input({ prompt = "Rename: ", default = entry.name }, function(name)
			if name == nil then
				return
			end

			vim.cmd.normal("C" .. name)
			vim.cmd.write()
		end)
	end
end

local function oil_delete()
	local mode = vim.fn.mode()
	vim.cmd.visual(mode == "v" and "d" or "dd")
	vim.cmd.write()
end

local function oil_setup_navigation_keys(echo)
	if vim.b.ao_oil_navigation_keys_enabled then
		vim.keymap.set("n", "h", function()
			require("oil.actions").parent.callback()
		end, { desc = "Go up one directory", buffer = true })
		vim.keymap.set("n", "l", function()
			require("oil.actions").select.callback()
		end, { desc = "Go up one directory", buffer = true })
		if echo then
			vim.notify("Oil: navigation keys enabled")
		end
	else
		pcall(vim.keymap.del, "n", "h", { buffer = true })
		pcall(vim.keymap.del, "n", "l", { buffer = true })
		vim.notify("Oil: navigation keys disabled")
	end
end

local function oil_toggle_navigation_keys()
	vim.b.ao_oil_navigation_keys_enabled = not vim.b.ao_oil_navigation_keys_enabled
	oil_setup_navigation_keys(true)
end

local function oil_touch()
	local oil = require("oil")
	local path = require("plenary.path")

	vim.ui.input({ prompt = "Create file (or directory): " }, function(name)
		if name == nil then
			return
		end

		if name == "." or name == ".." then
			print("Invalid file name: " .. name, vim.log.levels.ERROR)
			return
		end

		local dir = oil.get_current_dir()
		if not dir then
			return
		end

		local p = path:new(dir .. name)
		if p:exists() then
			vim.notify("File exists: " .. path.filename, vim.log.levels.WARN)
			return
		end

		vim.cmd.normal("O" .. name)
		vim.cmd.write()

		-- If the name doesn't end with /, it's not a directory
		if not name:match("/$") then
			vim.ui.select({ "Yes", "No" }, {
				prompt = "Add file to git?",
			}, function(choice)
				if choice == "Yes" then
					local full_path = dir .. name
					vim.fn.system({ "git", "add", full_path })
				end
			end)
		end
	end)
end

function M.goto_config_directory()
	---@diagnostic disable-next-line: param-type-mismatch
	proj.open(vim.fn.stdpath("config"))
end

M.plugins = {
	-- dired like filemanager
	{
		"stevearc/oil.nvim",
		keys = {
			{ "-", M.browse_directory("current"), desc = "Browse current directory" },
			{ "_", M.browse_directory("project"), desc = "Browse current project" },
			{ "<leader>/-", M.browse_directory("current", "vsplit"), desc = "Browse current directory in vsplit" },
			{ "<leader>/_", M.browse_directory("project", "vsplit"), desc = "Browse current project in vsplit" },
			{ "<leader>--", M.browse_directory("current", "split"), desc = "Browse current directory in split" },
			{ "<leader>-_", M.browse_directory("project", "split"), desc = "Browse current project in split" },
		},
		-- if you lazy load oil, things will be weird if you open a directory from the command line, even if you use the
		-- `VeryLazy` event, so do not lazy load.
		lazy = false,
		opts = function()
			return {
				columns = {
					"permissions",
					"size",
					"mtime",
					{ "icon", add_padding = false },
				},
				skip_confirm_for_simple_edits = true,
				lsp_file_methods = {
					autosave_changes = true,
				},
				cleanup_delay_ms = 30 * 1000,
				view_options = {
					show_hidden = true,
					is_always_hidden = function(name, _)
						return name == "." or name == ".."
					end,
				},
				keymaps = {
					["<cr>"] = "actions.select",
					["g/"] = "actions.select_vsplit",
					["g-"] = "actions.select_split",
					["gt"] = "actions.select_tab",
					["<C-p>"] = "actions.preview",
					["<C-c>"] = "actions.close",
					["<C-l>"] = "actions.refresh",
					["<C-h>"] = "actions.select_split",
					["<C-v>"] = "actions.select_vsplit",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["gk"] = { desc = "Toggle navigation keys", callback = oil_toggle_navigation_keys },
					["gR"] = "actions.refresh",
					["gr"] = { desc = "Rename", callback = oil_rename },
					["gn"] = { desc = "Create new file", callback = oil_touch },
					["gd"] = { desc = "Delete", callback = oil_delete },
					["g\\"] = "actions.toggle_trash",
					["g."] = "actions.toggle_hidden",
					["`"] = "actions.tcd",
					["~"] = "actions.refresh",
					["-"] = "actions.parent",
				},
				use_default_keymaps = false,
				constrain_cursor = "name",
			}
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		init = function()
			vim.g.ao_oil_navigation_keys_enabled = true
			vim.api.nvim_create_autocmd("FileType", {
				group = oil_setup_keys_group,
				pattern = "*",
				callback = function()
					if vim.bo.filetype ~= "oil" then
						return
					end

					vim.b.ao_oil_navigation_keys_enabled = true
					oil_setup_navigation_keys(false)
				end,
			})
		end,
	},
}

return M
