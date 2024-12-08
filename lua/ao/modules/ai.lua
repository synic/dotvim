return {
	{
		"yetone/avante.nvim",
		version = false, -- set this if you want to always pull the latest change
		keys = {
			{
				"<leader>aa",
				function()
					require("avante.api").ask()
				end,
				mode = { "x", "v" },
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
		},
		opts = {
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
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "<c-j>",
					prev = "<c-k>",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-c><C-c>",
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
				},
			},
		},
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"hrsh7th/nvim-cmp",
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
	},
}
