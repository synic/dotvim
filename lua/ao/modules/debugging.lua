local keymap = require("ao.keymap")

return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "LspAttach" },
    opts = {
      mode = "document_diagnostics",
      signs = {
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "",
      },
      icons = false,
      use_diagnostic_signs = true,
    },
    keys = keymap.trouble,
  },
  {
    "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
    keys = { { "<leader>ta", "<cmd>ToggleDiag<cr>", desc = "lsp diagnostics" } },
  },

  {
    "mfussenegger/nvim-dap",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        opts = {
          automatic_installation = true,
          ensure_installed = { "node2" },
          handlers = {},
          layouts = {
            elements = { "console" },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
      },
    },
    keys = keymap.nvim_dap,
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
            name = "Attach Docker (VSCode)",
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
    "rcarriga/nvim-dap-ui",
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
            elements = { "repl", "console" },
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
