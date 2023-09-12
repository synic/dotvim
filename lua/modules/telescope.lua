local functions = {}

functions.telescope_search_star = function()
  local builtin = require("telescope.builtin")
  local current_word = vim.fn.expand("<cword>")
  local project_dir = vim.fn.ProjectRootGuess()
  builtin.grep_string({
    cwd = project_dir,
    search = current_word,
  })
end

functions.telescope_search_cwd = function()
  local builtin = require("telescope.builtin")
  builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

functions.ctrlsf_search_for_term = function(prompt_bufnr)
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local prompt = current_picker:_get_prompt()
  vim.cmd(":CtrlSF " .. prompt)
end

functions.telescope_load_projects = function()
  local projects = require("project_nvim").get_recent_projects()
  if #projects == 0 then
    print("No projects found, loading directory...")
		vim.cmd(':Explore ' .. os.getenv("HOME") .. "/Projects")
  else
    require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
  end
end

functions.telescope_git_files = function()
  local utils = require("telescope.utils")
  local builtin = require("telescope.builtin")

  local _, ret, _ = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
  if ret == 0 then
    builtin.git_files()
  else
    functions.telescope_load_projects()
  end
end

functions.telescope_find_project_files = function()
  local builtin = require("telescope.builtin")

  -- `FindRootDirectory` comes from `airblade/vim-rooter`
  local project_root = vim.fn.FindRootDirectory()

  if project_root and project_root ~= "" then
    builtin.find_files({ cwd = project_root })
  else
    print("No project root was found, listing projects...")
    functions.telescope_load_projects()
  end
end

functions.telescope_new_tab_with_projects = function()
  vim.cmd(":tabnew<cr>")
  functions.telescope_load_projects()
end

return {
  {
    {
      "nvim-telescope/telescope.nvim",
      keys = {
        {
          "<leader>bb",
          "<cmd>lua require('telescope.builtin').buffers({ sort_mru=true, sort_lastused=true, icnore_current_buffer=true })<cr>",
          desc = "show buffers",
        },
        { "<leader>pg", functions.telescope_git_files, desc = "find git files" },
        { "<leader>sp", "<cmd>Telescope live_grep<cr>", desc = "search in project files" },
        { "<leader>sd", functions.telescope_search_cwd, desc = "search in current directory" },
        { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "show git branches" },
        { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "show git stashes" },
        { "<leader>lS", "<cmd>Telescope spell_suggest<cr>", desc = "spelling suggestions" },
        { "<leader>*", functions.telescope_search_star, desc = "search for term globally" },
        { "<leader>pp", functions.telescope_load_projects, desc = "projects" },
        { "<localleader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "code actions" },
        -- files
        { "<leader>lf", "<cmd>Telescope find_files<cr>", desc = "fuzzy find files" },
        { "<leader>pf", functions.telescope_find_project_files, desc = "find project file" },

        -- layouts
        { "<leader>wt", functions.telescope_new_tab_with_projects, desc = "new tab with project" },

        -- lists
        { "<leader>w<tab>", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "list layouts" },
        { "<leader>ls", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "snippets" },
        { "<leader>lT", "<cmd>Telescope colorscheme<cr>", desc = "themes" },
        { "<leader>lf", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
        { "<leader>lR", "<cmd>Telescope registers<cr>", desc = "registers" },
        { "<leader>lm", "<cmd>Telescope marks<cr>", desc = "marks" },
        { "<leader>lr", "<cmd>Telescope resume<cr>", desc = "resume last search" },
      },
      config = function()
        local telescope = require("telescope")

        telescope.setup({
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
              },
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
            project = {
              base_dirs = {
                { "~/Projects", max_depth = 1 },
              },
            },
            file_browser = {
              theme = "ivy",
              hijack_netrw = false,
            },
          },
          pickers = {
            buffers = {
              sort_mru = true,
              ignore_current_buffer = true,
            },
            live_grep = {
              mappings = {
                i = {
                  ["<C-e>"] = functions.ctrlsf_search_for_term,
                },
              },
            },
            grep_string = {
              mappings = {
                i = {
                  ["<C-e>"] = functions.ctrlsf_search_for_term,
                },
              },
            },
          },
        })

        telescope.load_extension("fzf")
        telescope.load_extension("projects")
        telescope.load_extension("file_browser")
        telescope.load_extension("ui-select")
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "dbakker/vim-projectroot",
        "airblade/vim-rooter",
        "ahmedkhalf/project.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "benfowler/telescope-luasnip.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
      },
    },
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "benfowler/telescope-luasnip.nvim",
  },
  {
    "LukasPietzschmann/telescope-tabs",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {},
  },
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = false,
        detection_methods = { "pattern", "lsp" },
        patterns = {
          ".git",
          "_darcs",
          ".hg",
          ".bzr",
          ".svn",
          "Makefile",
          "package.json",
          "setup.cfg",
          "setup.py",
          "pyproject.toml",
        },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data"),
      })
    end,
  },

  {
    "airblade/vim-rooter",
    config = function()
      vim.g.rooter_silent_chdir = 1
    end,
  },
  functions = functions,
}
