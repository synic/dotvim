local utils = require("ao.utils")
local module = {}

module.general_keys = {
  ["<leader>b"] = {
    name = "+buffers",
    keys = {
      { "<leader><tab>", "<cmd>b#<cr>", desc = "previous buffer", silent = true },
      { "<leader>bd", "<cmd>bdelete!<cr>", desc = "close current window and quit buffer", silent = true },
      { "<leader>bp", "1<C-g>:<C-U>echo v:statusmsg<cr>", desc = "show full buffer path", silent = true },
      { "<leader>bn", "<cmd>enew<cr>", desc = "new buffer", silent = true },
    },
  },
  ["<leader>w"] = {
    name = "+windows",
    keys = {
      { "<leader>wk", "<cmd>wincmd k<cr>", desc = "move up", silent = true },
      { "<leader>wj", "<cmd>wincmd j<cr>", desc = "move down", silent = true },
      { "<leader>wh", "<cmd>wincmd h<cr>", desc = "move left", silent = true },
      { "<leader>wl", "<cmd>wincmd l<cr>", desc = "move right", silent = true },
      { "<leader>w/", "<cmd>vs<cr>", desc = "split vertically", silent = true },
      { "<leader>w-", "<cmd>sp<cr>", desc = "split horizontally", silent = true },
      { "<leader>wc", "<cmd>close<cr>", desc = "close window", silent = true },
      { "<leader>wd", "<cmd>q<cr>", desc = "quit window", silent = true },
      { "<leader>w=", "<C-w>=", desc = "equalize windows", silent = true },
      { "<leader>wm", "<C-w>|", desc = "maximize window", silent = true },
      { "<leader>wH", "<cmd>wincmd H<cr>", desc = "move window left", silent = true },
      { "<leader>wJ", "<cmd>wincmd J<cr>", desc = "move window down", silent = true },
      { "<leader>wK", "<cmd>wincmd K<cr>", desc = "move window up", silent = true },
      { "<leader>wL", "<cmd>wincmd L<cr>", desc = "move window right", silent = true },
      { "<leader>wR", "<cmd>wincmd R<cr>", desc = "rotate windows", silent = true },
      { "<leader>wT", "<cmd>wincmd T<cr>", desc = "move to new layout", silent = true },
    },
  },
  ["<leader>l"] = {
    name = "+layouts/tabs",
    keys = {
      { "<leader>lT", "<cmd>tabnew<cr>", desc = "new layout", silent = true },
      { "<leader>l1", "1gt", desc = "go to layout #1", silent = true },
      { "<leader>l2", "2gt", desc = "go to layout #2", silent = true },
      { "<leader>l3", "3gt", desc = "go to layout #3", silent = true },
      { "<leader>l4", "4gt", desc = "go to layout #4", silent = true },
      { "<leader>l5", "5gt", desc = "go to layout #5", silent = true },
      { "<leader>l6", "6gt", desc = "go to layout #6", silent = true },
      { "<leader>l7", "7gt", desc = "go to layout #7", silent = true },
      { "<leader>l8", "8gt", desc = "go to layout #8", silent = true },
      { "<leader>l9", "9gt", desc = "go to layout #9", silent = true },
      { "<leader>lc", "<cmd>tabclose<cr>", desc = "close layout", silent = true },
      { "<leader>ln", "<cmd>tabnext<cr>", desc = "next layout", silent = true },
      { "<leader>lp", "<cmd>tabprev<cr>", desc = "previous layout", silent = true },
    },
  },
  ["<leader>d"] = { name = "+debug" },
  ["<leader>h"] = {
    name = "+help",
    keys = {
      {
        "<leader>hh",
        "<cmd>lua require('ao.utils').get_help()<cr>",
        desc = "show help",
        silent = true,
      },
      { "<leader>hw", "<cmd>help expand('<cword>')<cr>", desc = "show help for word under cursor" },
    },
  },
  ["<leader>g"] = { name = "+git" },
  ["<leader>s"] = { name = "+search" },
  ["<leader>p"] = { name = "+project" },
  ["<leader>t"] = {
    name = "+toggles",
    keys = {
      { "<leader>ts", "<cmd>let &hls = !&hls<cr>", desc = "toggle search highlights", silent = true },
      { "<leader>tr", "<cmd>let &rnu = !&rnu<cr>", desc = "toggle relative line numbers", silent = true },
      { "<leader>tn", "<cmd>let &nu = !&nu<cr>", desc = "toggle line number display", silent = true },
      { "<leader>tt", "<cmd>let &stal = !&stal<cr>", desc = "toggle tab display", silent = true },
    },
  },
  ["<leader>u"] = { name = "+ui" },
  ["<leader>e"] = { name = "+diagnostis" },
  ["<leader>P"] = { name = "+plugins" },
  ["<leader>c"] = { name = "+code" },
  ["<leader>q"] = { name = "+quit" },
  ["<localleader>d"] = { name = "+definitions" },
  misc = {
    keys = {
      {
        "<leader>C",
        "<cmd>lua vim.cmd('edit ' .. vim.fn.stdpath('config'))<cr>",
        desc = "manage config",
      },

      { "vig", "ggVG", desc = "select whole buffer", silent = true },
      { "<leader><localleader>", "<localleader>", desc = "local buffer options", silent = true },
      {
        "<leader>X",
        "<cmd>lua require('ao.utils').close_all_floating_windows()<cr>",
        desc = "close floating windows",
      },
      { "<leader>qq", "<cmd>qa!<cr>", desc = "quit" },
    },
  },
}

module.telescope = {
  {
    "<leader>bb",
    function()
      require("ao.modules.telescope").search_buffers()
    end,
    desc = "show buffers",
  },

  -- layouts/windows
  {
    "<leader>lt",
    function()
      require("ao.modules.telescope").new_tab_with_projects()
    end,
    desc = "new layout with project",
  },
  { "<leader>ll", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "list layouts" },

  -- search
  {
    "<leader>*",
    function()
      require("ao.modules.telescope").search_star()
    end,
    desc = "search for term in project",
  },
  {
    "<leader>sd",
    function()
      require("ao.modules.telescope").search_cwd()
    end,
    desc = "search in current directory",
  },
  { "<leader>ss", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "snippets" },
  { "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "spelling suggestions" },
  { "<leader>sT", "<cmd>Telescope colorscheme<cr>", desc = "themes" },
  { "<leader>so", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
  { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "registers" },
  { "<leader>sl", "<cmd>Telescope marks<cr>", desc = "marks" },
  { "<leader>.", "<cmd>Telescope resume<cr>", desc = "resume last search" },

  -- projects
  {
    "<leader>pP",
    function()
      require("ao.modules.telescope").find_project_files()
    end,
    desc = "find project file (inclusive)",
  },
  {
    "<leader>pf",
    function()
      require("ao.modules.telescope").find_project_files()
    end,
    desc = "find project file",
  },
  {
    "<leader>pg",
    function()
      require("ao.modules.telescope").git_files()
    end,
    desc = "find git files",
  },
  { "<leader>sp", "<cmd>Telescope live_grep<cr>", desc = "search project for text" },
}

module.project = {
  {
    "<leader>pp",
    function()
      require("ao.modules.telescope").load_projects()
    end,
    desc = "projects",
  },
}

module.trouble = {
  { "<leader>el", "<cmd>TroubleToggle<cr>", desc = "toggle trouble" },
  { "<leader>en", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "next error" },
  { "<leader>ep", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "next error" },
  { "<leader>ed", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "document diagnostics" },
  { "<leader>ew", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "workspace diagnostics" },
}

module.nvim_dap = {
  { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "toggle breakpoint" },
  { "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
  { "<leader>dd", "<cmd>lua require('dap').run_last()<cr>", desc = "run last" },
  { "<leader>dq", "<cmd>lua require('dap').close()<cr><cmd>lua require('dapui').close()<cr>", desc = "close" },
  { "<leader>dn", "<cmd>lua require('dap').step_over()<cr>", desc = "step over" },
  { "<leader>ds", "<cmd>lua require('dap').step_into()<cr>", desc = "step into" },
  { "<leader>do", "<cmd>lua require('dap').step_out()<cr>", desc = "step out" },
  { "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "continue" },
}

module.easymotion = {
  { "<leader><leader>", "<plug>(easymotion-overwin-f)", desc = "jump to location", mode = "n" },
  { "<leader><leader>", "<plug>(easymotion-bd-f)", desc = "jump to location", mode = "v" },
}

module.undotree = {
  { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "undo tree" },
}

module.flash = {
  {
    "s",
    mode = { "n", "o", "x" },
    function()
      require("flash").jump()
    end,
    desc = "flash",
  },
  {
    "S",
    mode = { "n", "o", "x" },
    function()
      require("flash").treesitter()
    end,
    desc = "flash treesitter",
  },
  {
    "r",
    mode = "o",
    function()
      require("flash").remote()
    end,
    desc = "remote flash",
  },
  {
    "R",
    mode = { "o", "x" },
    function()
      require("flash").treesitter_search()
    end,
    desc = "treesitter search",
  },
  {
    "<c-s>",
    mode = { "c" },
    function()
      require("flash").toggle()
    end,
    desc = "toggle flash search",
  },
}

module.lir = function()
  local actions = require("lir.actions")
  local mark_actions = require("lir.mark.actions")
  local clipboard_actions = require("lir.clipboard.actions")

  return {
    ["l"] = actions.edit,
    ["<return>"] = actions.edit,
    ["<C-s>"] = actions.split,
    ["<C-v>"] = actions.vsplit,
    ["S"] = actions.split,
    ["<C-t>"] = actions.tabedit,

    ["h"] = actions.up,
    ["q"] = actions.quit,
    ["<esc>"] = actions.quit,

    ["K"] = actions.mkdir,
    ["N"] = actions.newfile,
    ["R"] = actions.rename,
    ["@"] = actions.cd,
    ["Y"] = actions.yank_path,
    ["."] = actions.toggle_show_hidden,
    ["D"] = actions.delete,

    ["J"] = function()
      mark_actions.toggle_mark()
      vim.cmd("normal! j")
    end,
    ["C"] = clipboard_actions.copy,
    ["X"] = clipboard_actions.cut,
    ["P"] = clipboard_actions.paste,
  }
end

module.lsp_on_attach = function(_, bufnr)
  utils.map_keys({
    { "<localleader>r", vim.lsp.buf.rename, desc = "rename symbol", buffer = bufnr },
    { "<localleader>a", vim.lsp.buf.code_action, desc = "code actions", buffer = bufnr },

    { "gd", vim.lsp.buf.definition, desc = "goto definition", buffer = bufnr },
    { "gD", vim.lsp.buf.declaration, desc = "goto declaration", buffer = bufnr },
    { "gr", require("telescope.builtin").lsp_references, desc = "goto reference", buffer = bufnr },
    { "gI", require("telescope.builtin").lsp_implementations, desc = "goto implementation", buffer = bufnr },
    { "<localleader>d", vim.lsp.buf.type_definition, desc = "type definition", buffer = bufnr },
    {
      "<localleader>-",
      require("telescope.builtin").lsp_document_symbols,
      desc = "document symbols",
      buffer = bufnr,
    },
    {
      "<localleader>_",
      require("telescope.builtin").lsp_dynamic_workspace_symbols,
      desc = "workspace symbols",
      buffer = bufnr,
    },

    -- See `:help K` for why this keymap
    { "K", vim.lsp.buf.hover, desc = "hover documentation", buffer = bufnr },
    { "<C-k>", vim.lsp.buf.signature_help, desc = "signature documentation", buffer = bufnr },
  })
end

module.lspconfig = {
  { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
  {
    "gI",
    "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.implementation()<cr>",
    desc = "go to implementation in split",
  },
  { "gd", vim.lsp.buf.definition, desc = "go to definition" },
  { "gD", "<cmd>vsplit<cr><cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition in split" },
  { "<localleader>r", vim.lsp.buf.rename, desc = "rename symbol" },
}

module.scriptease = {
  { "<leader>sm", "<cmd>Messages<cr>", desc = "messages" },
}

module.ctrlsf = {
  {
    "<leader>sf",
    function()
      require("ao.modules.search").search_in_project_root()
    end,
    desc = "search in project root",
  },
}

module.gitsigns_on_attach = function(bufnr)
  local gs = package.loaded.gitsigns

  utils.map_keys({
		-- stylua: ignore start
		{ "]h", gs.next_hunk, desc = "next hunk", buffer = bufnr },
		{ "[h", gs.prev_hunk, desc = "prev hunk", buffer = bufnr },
		{ modes={ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", desc = "stage hunk", buffer = bufnr },
		{ modes={ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", desc = "reset hunk", buffer = bufnr },
		{ "<leader>ghS", gs.stage_buffer, desc = "stage buffer", buffer = bufnr },
		{ "<leader>ghu", gs.undo_stage_hunk, desc = "undo stage Hunk", buffer = bufnr },
		{ "<leader>ghR", gs.reset_buffer, desc = "reset buffer", buffer = bufnr },
		{ "<leader>ghp", gs.preview_hunk, desc = "preview hunk", buffer = bufnr },
		{ "<leader>ghb", function() gs.blame_line({ full = true }) end, desc = "blame line", buffer = bufnr },
		{ "<leader>ghd", gs.diffthis, desc = "diff this", buffer = bufnr },
		{ "<leader>ghD", function() gs.diffthis("~") end, desc = "diff this ~", buffer = bufnr },
		{ modes={ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", desc = "select hunk", buffer = bufnr },
  })
end

module.fugitive = {
  { "<leader>gb", ":Git blame<cr>", desc = "git blame" },
  { "<leader>ga", ":Git add %<cr>", desc = "git add" },
}

module.neogit = {
  {
    "<leader>gs",
    function()
      require("ao.modules.sourcecontrol").neogit_open()
    end,
    desc = "git status",
  },
}

module.true_zen = {
  { "<leader>tz", "<cmd>TZMinimalist<cr>", desc = "toggle zen mode" },
}

module.golden_ratio = {
  {
    "<leader>tg",
    function()
      require("ao.modules.ui").golden_ratio_toggle()
    end,
    desc = "golden Ratio",
  },
}

module.lazy = function()
  utils.map_keys({
    { "<leader>Pl", ":Lazy<cr>", desc = "plugins" },
    { "<leader>Pu", ":Lazy update<cr>", desc = "update plugins" },
    { "<leader>Ps", ":Lazy sync<cr>", desc = "sync plugins" },
    { "<leader>wM", ":ZoomToggle<cr>", desc = "zoom window" },
  })
end

module.zoom_toggle = function()
  utils.map_keys({
    { "<leader>wM", ":ZoomToggle<cr>", desc = "zoom window" },
  })
end

module.netrw = function()
  utils.map_keys({
    {
      "-",
      function()
        require("ao.modules.filesystem").netrw_current_file()
      end,
      desc = "browse current directory",
    },

    {
      "<leader>-",
      function()
        require("ao.modules.filesystem").netrw_current_file()
      end,
      desc = "browse current directory",
    },

    {
      "_",
      function()
        require("ao.modules.filesystem").netrw_current_project()
      end,
      desc = "browse current project",
    },

    {
      "<leader>_",
      function()
        require("ao.modules.filesystem").netrw_current_project()
      end,
      desc = "browse current project",
    },
  })
end

return module
