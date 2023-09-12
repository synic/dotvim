return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "lua" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "LuaLS/lua-language-server",
    },
    opts = function()
      local lsp = require("lspconfig")

      lsp.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "hs" },
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
        require("null-ls.builtins.formatting.stylua"),
      })
    end,
  },
}
