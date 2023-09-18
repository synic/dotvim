return {
  -- show diagnostics in gutter and quick fix list
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
    keys = {
      { "<leader>el", "<cmd>TroubleToggle<cr>", desc = "toggle trouble" },
      { "<leader>en", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "next error" },
      { "<leader>ep", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "next error" },
      { "<leader>ed", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "document diagnostics" },
      { "<leader>ew", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "workspace diagnostics" },
    },
  },

  -- ability to toggle diagnostics
  {
    "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
    keys = { { "<leader>ta", "<cmd>ToggleDiag<cr>", desc = "lsp diagnostics" } },
  },

  -- Debug Adapter Protocol plugin
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
        },
      },
    },
    keys = {
      { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "toggle breakpoint" },
      { "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
      { "<leader>dd", "<cmd>lua require('dap').run_last()<cr>", desc = "run last" },
      { "<leader>dq", "<cmd>lua require('dap').close()<cr><cmd>lua require('dapui').close()<cr>", desc = "close" },
      { "<leader>dn", "<cmd>lua require('dap').step_over()<cr>", desc = "step over" },
      { "<leader>ds", "<cmd>lua require('dap').step_into()<cr>", desc = "step into" },
      { "<leader>do", "<cmd>lua require('dap').step_out()<cr>", desc = "step out" },
      { "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
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
          -- {
          --   type = "pwa-node",
          --   request = "launch",
          --   name = "Launch file",
          --   program = "${file}",
          --   cwd = "${workspaceFolder}",
          -- },
          -- {
          --   type = "pwa-node",
          --   request = "attach",
          --   name = "Attach",
          --   processId = require("dap.utils").pick_process,
          --   cwd = "${workspaceFolder}",
          -- },
          -- {
          --   type = "pwa-node",
          --   request = "attach",
          --   name = "Attach Docker (VSCode)",
          --   port = 9229,
          --   restart = true,
          --   stopOnEntry = false,
          --   protocol = "inspector",
          --   trace = true,
          --   sourceMaps = true,
          --   localRoot = "${workspaceFolder}",
          --   cwd = "${workspaceFolder}",
          --   remoteRoot = "/app",
          -- },
        }
      end
    end,
  },

  -- UI for DAP
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    opts = {},
    dependencies = {
      "m00qek/baleia.nvim",
    },
    config = function(opts)
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

      vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { ctermbg = 0, bg = "#31353f" })

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
          { text = sign[1], texthl = sign[2] or "DapBreakpoint", linehl = sign[3], numhl = sign[3] }
        )
      end

      dapui.setup(opts)
    end,
  },
}
