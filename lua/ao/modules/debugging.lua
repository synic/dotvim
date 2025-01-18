---@type PluginModule
return {
	-- show diagnostics in gutter and quick fix list
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = { "LspAttach" },
		opts = {},
		keys = {
			{ "<leader>e<leader>", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Show error" },
			{ "<leader>el", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Toggle trouble" },
			{ "<leader>en", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next error" },
			{ "<leader>ep", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Next error" },
			{ "<leader>ew", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
		},
	},

	-- Debug Adapter Protocol plugin
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			{
				"jay-babu/mason-nvim-dap.nvim",
				opts = {
					automatic_installation = true,
					ensure_installed = {},
					handlers = {},
				},
			},
		},
		config = function()
			local dap = require("dap")

			for _, language in ipairs({ "typescript", "javascript" }) do
				dap.configurations[language] = {
					{
						request = "attach",
						sourceMaps = true,
						skipFiles = {
							"node_modules/**/*.js",
						},
						outFiles = {
							"${workspaceRoot}/dist/**/*.js",
						},
						protocol = "inspector",
						restart = true,
						type = "node2",
						name = "Attach Docker Node",
						localRoot = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
						remoteRoot = "/app",
						trae = true,
						port = 9229,
					},
				}
			end
		end,
	},

	-- UI for DAP
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			{ "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
			-- baleia displays color escape codes properly.
			-- currently used to colorize the dap-repl output.
			{
				"m00qek/baleia.nvim",
				submodules = false,
				version = "v1.3.0",
				opts = {},
				init = function()
					vim.api.nvim_create_user_command("BaleiaColorize", function()
						require("baleia").setup().once(vim.api.nvim_get_current_buf())
					end, {})
				end,
			},
		},
		keys = {
			{
				"<leader>db",
				"<cmd>lua require('dap').toggle_breakpoint()<cr>",
				desc = "Toggle breakpoint",
			},
			{ "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
			{ "<leader>dd", "<cmd>lua require('dap').run_last()<cr>", desc = "Run last" },
			{
				"<leader>dq",
				"<cmd>lua require('dap').close()<cr><cmd>lua require('dapui').close()<cr>",
				desc = "Close",
			},
			{ "<leader>dn", "<cmd>lua require('dap').step_over()<cr>", desc = "Step over" },
			{ "<leader>ds", "<cmd>lua require('dap').step_into()<cr>", desc = "Step into" },
			{ "<leader>do", "<cmd>lua require('dap').step_out()<cr>", desc = "Step out" },
			{ "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
		},
		config = function(_, opts)
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

			local icons = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = " ",
				BreakpointCondition = " ",
				BreakpointRejected = { " ", "DiagnosticError" },
				LogPoint = ".>",
			}

			for name, sign in pairs(icons) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					---@diagnostic disable-next-line: assign-type-mismatch
					{ text = sign[1], texthl = sign[2] or "DapBreakpoint", linehl = sign[3], numhl = sign[3] }
				)
			end

			dapui.setup(opts)
		end,
	},
}
