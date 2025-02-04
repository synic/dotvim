local laststatus_augroup = vim.api.nvim_create_augroup("AvanteLastStatusChanger", { clear = true })

--- Fix keyboard mappings.
---
--- Sometimes when Avante crashes, it leaves the keys mapped so things like `A` won't append at the end of the line.
--- Very annoying. It also leaves extra avante windows open, which are difficult to focus and close, so automatically
--- close all of those as well.
local function reset_avante()
	local avante = require("avante")
	local sidebar = avante.get()
	pcall(vim.keymap.del, "n", "A")
	pcall(vim.keymap.del, "n", "a")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local had_value, ft = pcall(vim.fn.getbufvar, buf, "&filetype")
		if had_value and ft:find("^Avante") ~= nil or (sidebar and sidebar:in_code_win()) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

---@type PluginModule
return {
	{
		"yetone/avante.nvim",
		keys = {
			{
				"<leader>aa",
				function()
					require("avante.api").ask()
				end,
				mode = { "n", "v" },
				desc = "avante: ask",
			},
			{
				"<leader>ae",
				function()
					require("avante.api").edit()
				end,
				mode = { "v" },
				desc = "avante: edit",
			},
			{
				"<leader>af",
				function()
					require("avante.api").focus()
				end,
				mode = { "n" },
				desc = "avante: focus",
			},
			{
				"<leader>ar",
				function()
					require("avante.api").refresh()
				end,
				mode = { "n" },
				desc = "avante: refresh",
			},
			{
				"<leader>at",
				"<Plug>(AvanteToggle)",
				mode = { "n" },
				desc = "avante: toggle",
			},
			{
				"<leader>ad",
				"<Plug>(AvanteToggleDebug)",
				mode = { "n" },
				desc = "avante: toggle debug",
			},
			{
				"<leader>ah",
				"<Plug>(AvanteToggleHint)",
				mode = { "n" },
				desc = "avante: toggle hint",
			},
			{
				"<leader>as",
				"<Plug>(AvanteToggleSuggestion)",
				mode = { "n" },
				desc = "avante: toggle suggestion",
			},
			{
				"<leader>aR",
				function()
					require("avante.repo_map").show()
				end,
				mode = { "n" },
				desc = "avante: display repo map",
			},
			{
				"<leader>ax",
				reset_avante,
				desc = "avante: reset",
			},
		},
		opts = {
			window = {
				width = 25,
			},
			mappings = {
				diff = {
					ours = "co",
					theirs = "ct",
					all_theirs = "ca",
					both = "cb",
					cursor = "cc",
					next = "]x",
					prev = "[x",
				},
				suggestion = {
					accept = "<m-l>",
					next = "<m-]>",
					prev = "<m-[>",
					dismiss = "<c-]>",
				},
				jump = {
					next = "<c-j>",
					prev = "<c-k>",
				},
				submit = {
					normal = "<cr>",
					insert = "<c-c><c-c>",
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					switch_windows = "<tab>",
					reverse_switch_windows = "<s-tab>",
				},
			},
			file_selector = {
				provider = "snacks",
			},
		},
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
					},
				},
			},
			"MeanderingProgrammer/render-markdown.nvim",
		},
		config = function(_, opts)
			local avante = require("avante")
			local laststatus = vim.o.laststatus

			vim.api.nvim_create_autocmd("WinEnter", {
				group = laststatus_augroup,
				callback = function()
					local sidebar = avante.get()

					-- I like laststatus=2, but avante looks like crap with that, so set laststatus=3 when it is open, and set
					-- it back when it's not
					if sidebar ~= nil and sidebar:is_open() then
						vim.o.laststatus = 3
					else
						vim.o.laststatus = laststatus
					end
				end,
			})

			avante.setup(opts)
		end,
	},
}
