local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

return {
  -- main completion engine
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter" },
    version = false,
    opts = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")

      return {
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = {
            side_padding = 1,
            border = border("TelescopeBorder"),
            winhighlight = "Normal:Normal,TelescopeBorder:Normal,CursorLine:TelescopeSelection,Search:None",
            scrollbar = false,
          },
          documentation = {
            border = border("TelescopeBorder"),
            winhighlight = "Normal:TelescopeBorder,TelescopeBorder:Normal,CursorLine:TelescopeSelection,Search:None",
            side_padding = 1,
          },
        },
        experimental = {
          ghost_text = true,
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
          ["<Tab>"] = cmp.mapping(function(fallback)
            local col = vim.fn.col(".") - 1

            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- lsp completion
          { name = "nvim_lua" }, -- lua completion for the nvim api
          { name = "path" }, -- paths (filesystem)
          { name = "luasnip" }, -- snippets
          {
            name = "buffer", -- completion from open buffers
            option = {
              get_bufnrs = function()
                -- return visible buffers only
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            },
          },
        }),
        formatting = {
          fields = { "abbr", "menu", "kind" },
          format = lspkind.cmp_format({
            mode = "symbol_text",
            -- The function below will be called before any actual modifications
            -- from lspkind so that you can provide more controls on popup
            -- customization.
            -- (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(_, vim_item)
              -- set fixed width of cmp window
              local width = 30
              local ellipses_char = "…"
              local label = vim_item.abbr
              local truncated_label = vim.fn.strcharpart(label, 0, width)
              if truncated_label ~= label then
                vim_item.abbr = truncated_label .. ellipses_char
              elseif string.len(label) < width then
                local padding = string.rep(" ", width - string.len(label))
                vim_item.abbr = label .. padding
              end
              return vim_item
            end,
            menu = {
              spell = "[Dict]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[API]",
              path = "[Path]",
              luasnip = "[Snip]",
            },
          }),
        },
      }
    end,
    dependencies = {
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },
}
