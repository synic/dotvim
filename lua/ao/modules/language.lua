local utils = require("ao.utils")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local flags = { allow_incremental_sync = true, debounce_text_changes = 200 }

local function lsp_on_attach(_, bufnr)
  utils.map_keys({
    { "<localleader>r", vim.lsp.buf.rename, desc = "Rename symbol", buffer = bufnr },
    { "<localleader>a", vim.lsp.buf.code_action, desc = "Code actions", buffer = bufnr },
    { "gd", vim.lsp.buf.definition, desc = "Goto definition", buffer = bufnr },
    { "gD", vim.lsp.buf.declaration, desc = "Goto declaration", buffer = bufnr },
    {
      "g/",
      "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.definition()<cr>",
      desc = "Goto def in vsplit",
      buffer = bufnr,
    },
    {
      "g-",
      "<cmd>split<cr><cmd>lua vim.lsp.buf.definition()<cr>",
      desc = "Goto def in hsplit",
      buffer = bufnr,
    },
    {
      "gr",
      require("telescope.builtin").lsp_references,
      desc = "Goto reference",
      buffer = bufnr,
    },
    {
      "gI",
      require("telescope.builtin").lsp_implementations,
      desc = "Goto implementation",
      buffer = bufnr,
    },
    {
      "<localleader>d",
      vim.lsp.buf.type_definition,
      desc = "Type definition",
      buffer = bufnr,
    },
    {
      "<localleader>-",
      require("telescope.builtin").lsp_document_symbols,
      desc = "Document symbols",
      buffer = bufnr,
    },
    {
      "<localleader>_",
      require("telescope.builtin").lsp_dynamic_workspace_symbols,
      desc = "Workspace symbols",
      buffer = bufnr,
    },
    {
      -- see :help K for why it's this keymap
      "K",
      "<cmd>lua vim.lsp.buf.hover()<cr>",
      desc = "Show definition",
      buffer = bufnr,
    },
  })
end

return {
  -- configure mason packages with LSP
  {
    "williamboman/mason.nvim",
    config = true,
    lazy = false, -- mason does not like to be lazy loaded
    keys = {
      { "<leader>cM", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "clangd",
        "svelte",
        "eslint",
        "gopls",
        "templ",
        "cmake",
        "htmx",
        "tailwindcss",
      },
      automatic_installation = true,
    },
    lazy = true,
    config = function(_, opts)
      local lsp = require("lspconfig")
      local m = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      vim.filetype.add({ extension = { templ = "templ" } })

      m.setup(opts)
      m.setup_handlers({
        ["lua_ls"] = function()
          lsp.lua_ls.setup({
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            flags = flags,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim", "hs" } },
                completion = { callSnippet = "Replace", autoRequire = true, displayContext = 7 },
              },
            },
          })
        end,

        ["htmx"] = function()
          lsp.htmx.setup({
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            filetypes = { "html", "templ" },
          })
        end,

        ["tailwindcss"] = function()
          lsp.tailwindcss.setup({
            on_attach = lsp_on_attach,
            capabilities = capabilities,
            filetypes = { "templ", "astro", "javascript", "typescript", "react" },
            init_options = { userLanguages = { templ = "html" } },
          })
        end,

        ["rust_analyzer"] = function()
          lsp.rust_analyzer.setup({
            flags = flags,
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                },
                checkOnSave = {
                  allFeatures = true,
                  command = "clippy",
                },
                procMacro = {
                  ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                  },
                },
              },
            },
          })
        end,

        ["gopls"] = function()
          lsp.gopls.setup({
            flags = flags,
            capabilities = capabilities,
            settings = {
              gpls = {
                completeUnimported = true,
                analysis = {
                  unusedparams = true,
                },
              },
            },
          })
        end,

        -- generic setup function for servers without explicit configuration
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            flags = flags,
          })
        end,
      })
    end,
  },

  -- lsp
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/nvim-cmp",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    keys = {
      { "gi", vim.lsp.buf.implementation, desc = "Go to implementation" },
      {
        "gI",
        "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.implementation()<cr>",
        desc = "Go to implementation in split",
      },
      { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
      { "g/", "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to definition in split" },
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        inlay_hints = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      },
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = { border = "rounded" },
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
      local lsp = require("lspconfig")
      local defaults = lsp.util.default_config
      defaults.capabilities =
        vim.tbl_deep_extend("force", defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "BufReadPre", "BufNewFile" },
      },
    },
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = { enable = true },
      -- indent = { enable = true },
      auto_install = true,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "Around block" },
            ["ik"] = { query = "@block.inner", desc = "Inside block" },
            ["ac"] = { query = "@class.outer", desc = "Around class" },
            ["ic"] = { query = "@class.inner", desc = "Inside class" },
            ["a?"] = { query = "@conditional.outer", desc = "Around conditional" },
            ["i?"] = { query = "@conditional.inner", desc = "Inside conditional" },
            ["af"] = { query = "@function.outer", desc = "Around function" },
            ["if"] = { query = "@function.inner", desc = "Inside function" },
            ["al"] = { query = "@loop.outer", desc = "Around loop" },
            ["il"] = { query = "@loop.inner", desc = "Inside loop" },
            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@block.outer"] = "V",
            ["@conditional.outer"] = "V",
            ["@loop.outer"] = "V",
            ["@class.outer"] = "V", -- blockwise
          },
          include_surrounding_whitespace = false,
        },

        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        lsp_interop = {
          enable = true,
          border = "none",
          peek_definition_code = {
            ["<localleader>df"] = "@function.outer",
            ["<localleader>dF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- automatically close tags in jsx, tsx
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- diagnostics and formatting
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "jose-elias-alvarez/typescript.nvim",
        ft = { "typescript", "javascript" },
        opts = { server = { on_attach = lsp_on_attach } },
      },
      "davidmh/cspell.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local ns = require("null-ls")

      return {
        debug = true,
        sources = {
          -- formatting
          ns.builtins.formatting.trim_whitespace, -- general
          ns.builtins.formatting.stylua, -- lua
          ns.builtins.formatting.black, -- python
          ns.builtins.formatting.prettierd.with({ filetypes = { "typescript", "javascript" } }),
          ns.builtins.formatting.prettier.with({ filetypes = { "svelte" } }),
          ns.builtins.formatting.rustfmt,
          ns.builtins.formatting.gofmt,
          ns.builtins.formatting.goimports_reviser,
          ns.builtins.formatting.golines,
          ns.builtins.formatting.templ,

          -- diagnostics
          ns.builtins.diagnostics.gitlint,
          ns.builtins.diagnostics.ruff,
          ns.builtins.diagnostics.mypy,
          ns.builtins.diagnostics.yamllint,
          ns.builtins.diagnostics.hadolint, -- Dockerfile
          ns.builtins.diagnostics.markdownlint_cli2,

          -- actions
          ns.builtins.code_actions.gitsigns,
          require("typescript.extensions.null-ls.code-actions"),
        },

        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(c)
                    return c.name == "null-ls"
                  end,
                })
              end,
            })
          else
            print("client did not support formatting")
          end
        end,
      }
    end,
  },

  -- fidget.nvim shows lsp and null-ls status at the bottom right of the screen
  { "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach", opts = {} },

  -- css
  { "ap/vim-css-color", ft = "css" },

  -- dart
  { "dart-lang/dart-vim-plugin", ft = "dart" },

  -- python
  { "jmcantrell/vim-virtualenv", ft = "python" },

  -- vim scripting utilities
  {
    "tpope/vim-scriptease",
    keys = {
      { "<leader>sm", "<cmd>Messages<cr>", desc = "Messages" },
    },
  },
}
