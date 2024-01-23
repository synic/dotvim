local utils = require("ao.utils")

local function telescope_grep_project_for_term()
  local status, project = pcall(require, "project_nvim.project")

  if not status then
    print("Unable to determine project root")
    return
  end

  local builtin = require("telescope.builtin")
  local current_word = vim.fn.expand("<cword>")
  local project_root, _ = project.get_project_root()

  builtin.grep_string({
    cwd = project_root,
    search = current_word,
  })
end

local function telescope_grep_working_directory()
  local builtin = require("telescope.builtin")
  builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

local function ctrlsf_search_for_term(prompt_bufnr)
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local prompt = current_picker:_get_prompt()
  vim.cmd("CtrlSF " .. prompt)
end

local function telescope_load_projects()
  local status, projects = pcall(require, "project_nvim")
  if status then
    if not #projects.get_recent_projects() then
      print("No projects found")
      return
    end
  end

  vim.schedule(function()
    require("telescope").extensions.projects.projects({ layout_config = { width = 0.5, height = 0.3 } })
  end)
end

local function telescope_git_files()
  local util = require("telescope.utils")
  local builtin = require("telescope.builtin")

  local _, ret, _ = util.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
  if ret == 0 then
    builtin.git_files()
  else
    telescope_load_projects()
  end
end

local function telescope_find_project_files()
  local builtin = require("telescope.builtin")

  local status, project = pcall(require, "project_nvim.project")

  if not status then
    print("Unable to determine project root")
    return
  end

  local project_root, _ = project.get_project_root()

  if project_root and project_root ~= "" then
    builtin.find_files({ cwd = project_root })
  else
    print("No project root was found, listing projects...")
    telescope_load_projects()
  end
end

local function telescope_new_tab_with_projects()
  vim.cmd.tabnew()
  telescope_load_projects()
end

local function telescope_search_buffers()
  require("telescope.builtin").buffers({
    sort_mru = true,
    sort_lastused = true,
    ignore_current_buffer = true,
  })
end

return {
  -- fuzzy finder and list manager
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>bb", telescope_search_buffers, desc = "Show buffers" },

      -- layouts/windows
      {
        "<leader>lt",
        telescope_new_tab_with_projects,
        desc = "New layout with project",
      },
      { "<leader>ll", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "List layouts" },

      -- search
      { "<leader>*", telescope_grep_project_for_term, desc = "Search for term in project", mode = { "n", "v" } },
      { "<leader>sd", telescope_grep_working_directory, desc = "Search in current directory" },
      { "<leader>ss", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "Snippets" },
      { "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
      { "<leader>sT", "<cmd>Telescope colorscheme<cr>", desc = "Themes" },
      { "<leader>,", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sl", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>sb", "<cmd>Telescope builtin<cr>", desc = "List pickers" },

      -- projects
      { "<leader>pf", telescope_find_project_files, desc = "Find project file" },
      { "<leader>pg", telescope_git_files, desc = "Find git files" },
      { "<leader>sp", "<cmd>Telescope live_grep<cr>", desc = "Search project for text" },
    },

    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-/>"] = actions.file_vsplit,
              ["<C-->"] = actions.file_split,
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
        },
        pickers = {
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
          },
          live_grep = {
            mappings = {
              i = {
                ["<C-e>"] = ctrlsf_search_for_term,
              },
            },
          },
          grep_string = {
            mappings = {
              i = {
                ["<C-e>"] = ctrlsf_search_for_term,
              },
            },
          },
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "LukasPietzschmann/telescope-tabs",
      "benfowler/telescope-luasnip.nvim",
      {
        "nvim-telescope/telescope-ui-select.nvim",

        config = function()
          utils.on_load("telescope.nvim", function()
            require("telescope").load_extension("ui-select")
          end)
        end,
      },

      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
        config = function()
          utils.on_load("telescope.nvim", function()
            require("telescope").load_extension("fzf")
            print("fzf is loaded!")
          end)
        end,
      },
    },
  },

  -- telescope project support
  -- can load and run separately from telescope, so it is not listed as a dependency.
  {
    "ahmedkhalf/project.nvim",
    keys = {
      { "<leader>pp", telescope_load_projects, desc = "Projects" },
    },
    lazy = false,
    config = function()
      require("project_nvim").setup({
        manual_mode = false,
        silent_chdir = true,
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
        exclude_dirs = { "node_modules" },
        show_hidden = false,
        datapath = vim.fn.stdpath("data"),
      })

      utils.on_load("telescope.nvim", function()
        require("telescope").load_extension("projects")
      end)
    end,
  },
}
