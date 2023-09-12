return {
  { "jmcantrell/vim-virtualenv", ft = "python" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "ninja", "python", "rst", "toml", "htmldjango" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local lsp = require("lspconfig")

      lsp.pylsp.setup({
        settings = {
          pylsp = {
            plugins = {
              ruff = {
                enabled = true,
                extendSelect = { "I" },
                lineLength = 120,
              },
            },
          },
        },
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require("null-ls.builtins.formatting.black"),
        require("null-ls.builtins.diagnostics.ruff"),
        require("null-ls.builtins.diagnostics.mypy"),
      })
    end,
  },
}
