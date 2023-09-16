local keymap = require("ao.keymap")

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "tsserver",
        "cssls",
        "ruff_lsp",
        "clangd",
      },
    },
    lazy = true,
    config = function(_, opts)
      local m = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      m.setup(opts)
      m.setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({ capabilities = capabilities })
        end,

        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            on_attach = keymap.lsp_on_attach,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim", "hs" } },
                completion = { callSnippet = "Replace" },
              },
            },
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
      { "williamboman/mason.nvim", config = true, lazy = false },
    },
    keys = keymap.lspconfig,
    config = function()
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
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "query",
        "vim",
        "vimdoc",
        "regex",
        "lua",
        "python",
        "graphql",
        "css",
        "html",
        "markdown",
        "markdown_inline",
      },
      auto_install = true,
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = { query = "@class.inner", desc = "select inner part of a class region" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "next class start" },
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
            [",df"] = "@function.outer",
            [",dF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      local ns = require("null-ls")

      return {
        debug = true,
        sources = {
          -- formatting
          ns.builtins.formatting.trim_whitespace,
          ns.builtins.formatting.stylua,
          ns.builtins.formatting.black,
          ns.builtins.formatting.prettierd,

          -- diagnostics
          ns.builtins.diagnostics.gitlint,
          ns.builtins.diagnostics.ruff,
          ns.builtins.diagnostics.mypy,
          ns.builtins.diagnostics.eslint,

          -- actions
          ns.builtins.code_actions.gitsigns,
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
          end
        end,
      }
    end,
  },

  { "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach", opts = {} },

  -- css
  { "ap/vim-css-color", ft = "css" },

  -- dart
  { "dart-lang/dart-vim-plugin", ft = "dart" },

  -- graphql
  { "jparise/vim-graphql", ft = "graphql" },

  -- python
  { "jmcantrell/vim-virtualenv", ft = "python" },

  -- vim
  { "tpope/vim-scriptease", keys = keymap.scriptease },
}
