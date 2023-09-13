return {
  {
    "hrsh7th/nvim-cmp",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = { expand = function() end },
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<C-g>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          ["<S-Tab>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
          { name = "buffer" },
        }),
        format = function(entry, vim_item)
          if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
            vim_item.menu = entry.completion_item.detail
          else
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            vim_item.kind = require("lspkind").presets.codicons[vim_item.kind] .. "  " .. vim_item.kind
          end
          return vim_item
        end,
      })

      vim.cmd([[
				set completeopt=menuone,noinsert,noselect
				highlight! default link CmpItemKind CmpItemMenuDefault
			]])
    end,
    dependencies = { "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" },
  },
}
