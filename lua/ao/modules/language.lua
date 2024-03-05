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
      "gs",
      require("telescope.builtin").lsp_document_symbols,
      desc = "Document symbols",
      buffer = bufnr,
    },
    {
      "gW",
      require("telescope.builtin").lsp_dynamic_workspace_symbols,
      desc = "Workspace symbols",
      buffer = bufnr,
    },
    {
      "g=",
      "<cmd>lua vim.lsp.buf.format()<cr>",
      desc = "Format document",
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
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    lazy = true,
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
    init = function()
      vim.filetype.add({ extension = { templ = "templ" } })
    end,
    config = function(_, opts)
      local lsp = require("lspconfig")
      local m = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
            flags = flags,
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            filetypes = { "html", "templ" },
          })
        end,

        ["tailwindcss"] = function()
          lsp.tailwindcss.setup({
            flags = flags,
            on_attach = lsp_on_attach,
            capabilities = capabilities,
            filetypes = { "templ", "astro", "javascript", "typescript", "react", "css" },
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

        ["templ"] = function()
          lsp.templ.setup({
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            flags = flags,
            filetypes = { "templ" },
          })
        end,

        ["gopls"] = function()
          lsp.gopls.setup({
            flags = flags,
            capabilities = capabilities,
            on_attach = lsp_on_attach,
            settings = {
              gopls = {
                buildFlags = { "-tags=debug" },
                completeUnimported = true,
                analyses = {
                  unusedparams = true,
                  fieldalignment = true,
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
      { "folke/neodev.nvim", ft = "lua" },
      {
        "jose-elias-alvarez/typescript.nvim",
        ft = { "typescript", "javascript" },
        opts = { server = { on_attach = lsp_on_attach } },
      },
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
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      { "windwp/nvim-ts-autotag", config = true },
      { "nvim-treesitter/nvim-treesitter-context", config = true },
    },
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      auto_install = true,
      ensure_installed = {
        "typescript",
        "javascript",
        "lua",
        "vimdoc",
        "vim",
        "python",
        "go",
        "rust",
        "markdown",
        "markdown_inline",
        "html",
        "htmldjango",
        "css",
      },
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
            ["gF"] = "@function.outer",
            ["gC"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- diagnostics and formatting
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/typescript.nvim",
      "davidmh/cspell.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local ns = require("null-ls")
      local custom = require("ao.custom.none-ls")

      -- only use none-ls for formatting these filetypes; the rest can use any formatter
      local only_nonels_formatting_filetypes = {
        "lua",
        "typescript",
        "javascript",
        "go",
        "svelte",
      }

      return {
        sources = {
          -- formatting
          ns.builtins.formatting.stylua, -- lua
          ns.builtins.formatting.black, -- python
          ns.builtins.formatting.prettierd.with({
            filetypes = { "typescript", "javascript" },
          }),
          ns.builtins.formatting.prettier.with({
            filetypes = { "svelte" },
          }),
          ns.builtins.formatting.gofmt,
          ns.builtins.formatting.goimports_reviser,
          ns.builtins.formatting.golines,
          ns.builtins.formatting.rustywind.with({
            filetypes = { "typescript", "javascript", "css", "templ", "html" },
          }),
          custom.trim_whitespace,

          -- diagnostics
          ns.builtins.diagnostics.gitlint,
          ns.builtins.diagnostics.mypy,
          ns.builtins.diagnostics.yamllint,
          ns.builtins.diagnostics.hadolint, -- Dockerfile
          ns.builtins.diagnostics.markdownlint_cli2,

          -- -- actions
          require("typescript.extensions.null-ls.code-actions"),
        },

        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                local buf = vim.api.nvim_get_current_buf()
                local ft = vim.bo[buf].filetype
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(c)
                    if utils.table_contains(only_nonels_formatting_filetypes, ft) then
                      return c.name == "null-ls"
                    end
                    return true
                  end,
                })
              end,
            })
          end
        end,
      }
    end,
  },

  -- dart
  { "dart-lang/dart-vim-plugin", ft = "dart" },

  -- python
  { "jmcantrell/vim-virtualenv", ft = "python" },
}
