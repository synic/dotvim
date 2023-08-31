return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = true,
		opts = {
			mode = "document_diagnostics",
		},
		keys = {
			{ "<space>el", "<cmd>TroubleToggle<cr>", desc = "toggle trouble" },
			{ "<space>en", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "next error" },
			{ "<space>ep", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "next error" },
			{ "<space>ed", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "document diagnostics" },
			{ "<space>ew", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "workspace diagnostics" },
		},
	},
	{
		"WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
		keys = { "<space>ta", "<cmd>ToggleDiag<cr>", desc = "lsp diagnostics" },
	},
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{ "<space>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "toggle breakpoint" },
			{ "<space>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
			{ "<space>dd", "<cmd>lua require('dap').run_last()<cr>", desc = "run last" },
			{ "<space>dq", "<cmd>lua require('dap').close()<cr>", desc = "close" },
			{ "<space>dn", "<cmd>lua require('dap').step_over()<cr>", desc = "step over" },
			{ "<space>ds", "<cmd>lua require('dap').step_into()<cr>", desc = "step into" },
			{ "<space>do", "<cmd>lua require('dap').step_out()<cr>", desc = "step out" },
			{ "<space>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
		},
		config = function()
			local dap = require("dap")
			require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "typescript", "javascript" } })

			for _, language in ipairs({ "typescript", "javascript" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach Docker",
						port = 9229,
						restart = true,
						stopOnEntry = false,
						protocol = "inspector",
						trace = true,
						sourceMaps = true,
						localRoot = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
						remoteRoot = "/app",
					},
				}
			end
		end,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = { "mfussenegger/nvim-dap" },
		lazy = true,
		opts = {
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
		},
	},
	{
		"microsoft/vscode-js-debug",
		build = "rm -rf out && npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out && git reset --hard",
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		lazy = true,
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				expand_lines = vim.fn.has("nvim-0.7") == 1,
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							"breakpoints",
							"stacks",
							"watches",
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 0.25,
						position = "bottom",
					},
				},
				controls = {
					enabled = true,
					element = "repl",
					icons = {
						pause = "",
						play = "",
						step_into = "",
						step_over = "",
						step_out = "",
						step_back = "",
						run_last = "↻",
						terminate = "□",
					},
				},
				floating = {
					max_height = nil,
					max_width = nil,
					border = "single",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				windows = { indent = 1 },
				render = {
					max_type_length = nil,
					max_value_lines = 100,
				},
			})
		end,
	},
}
