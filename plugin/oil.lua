local oil_setup_keys_group = vim.api.nvim_create_augroup("OilSetupKeys", { clear = true })

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

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
			vim.notify("File exists: " .. dir .. name, vim.log.levels.WARN)
			return
		end

		vim.cmd.normal("O" .. name)
		vim.cmd.write()
	end)
end

local function oil_add_to_git()
	local oil = require("oil")
	local entry = oil.get_cursor_entry()
	if entry ~= nil then
		local full_path = oil.get_current_dir() .. "/" .. entry.parsed_name
		vim.fn.system({ "git", "add", full_path })
		vim.notify("Added file to git: " .. entry.parsed_name)
	end
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

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("oil").setup({
			columns = {
				"permissions",
				"size",
				"mtime",
				{ "icon", add_padding = false },
			},
			skip_confirm_for_simple_edits = true,
			watch_for_changes = true,
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
				["<c-p>"] = "actions.preview",
				["<c-c>"] = "actions.close",
				["<c-l>"] = "actions.refresh",
				["<c-r>"] = "actions.refresh",
				["<c-h>"] = "actions.select_split",
				["<c-v>"] = "actions.select_vsplit",
				["ga"] = { desc = "Oil: Add to git", callback = oil_add_to_git },
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["gn"] = { desc = "Oil: Create file", callback = oil_touch },
				["gk"] = { desc = "Oil: Toggle navigation keys", callback = oil_toggle_navigation_keys },
				["gR"] = "actions.refresh",
				["g\\"] = "actions.toggle_trash",
				["g."] = "actions.toggle_hidden",
				["`"] = "actions.tcd",
				["~"] = "actions.refresh",
				["-"] = "actions.parent",
			},
			use_default_keymaps = false,
			constrain_cursor = "name",
		})

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
})
