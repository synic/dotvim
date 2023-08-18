return {
	"w0rp/ale",
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				mode = "document_diagnostics",
			})
			vim.keymap.set("n", "<space>el", ":TroubleToggle<cr>")
			vim.keymap.set("n", "<space>en", ":lua vim.diagnostic.goto_next()<cr>")
			vim.keymap.set("n", "<space>ep", ":lua vim.diagnostic.goto_prev()<cr>")
			vim.keymap.set("n", "<space>ed", ":TroubleToggle document_diagnostics<cr>")
			vim.keymap.set("n", "<space>ew", ":TroubleToggle workspace_diagnostics<cr>")
		end,
	},
	{
		"WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
		config = function()
			require("toggle_lsp_diagnostics").init()

			vim.keymap.set("n", "<space>ta", ":ToggleDiag<cr>")
		end,
	},
	{
		"mfussenegger/nvim-dap",
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

			vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
			vim.keymap.set("n", "<space>dc", dap.continue)
			vim.keymap.set("n", "<space>dd", dap.run_last)
			vim.keymap.set("n", "<space>dq", dap.close)
			vim.keymap.set("n", "<space>dn", dap.step_over)
			vim.keymap.set("n", "<space>ds", dap.step_into)
			vim.keymap.set("n", "<space>do", dap.step_out)
			vim.keymap.set("n", "<space>dc", dap.continue)
		end,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-vscode-js").setup({
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			})
		end,
	},
	{
		"microsoft/vscode-js-debug",
		build = "rm -rf out && npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out && git reset --hard",
	},

	-- NOTE: dapui is the plugin causing the "setup called twice" message
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
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
