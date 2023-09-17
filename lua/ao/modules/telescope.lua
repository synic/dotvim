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
    icnore_current_buffer = true,
  })
end

return {
  -- fuzzy finder and list manager
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>bb", telescope_search_buffers, desc = "show buffers" },

      -- layouts/windows
      {
        "<leader>lt",
        telescope_new_tab_with_projects,
        desc = "new layout with project",
      },
      { "<leader>ll", "<cmd>lua require('telescope-tabs').list_tabs()<cr>", desc = "list layouts" },

      -- search
      { "<leader>*", telescope_grep_project_for_term, desc = "search for term in project" },
      { "<leader>sd", telescope_grep_working_directory, desc = "search in current directory" },
      { "<leader>ss", "<cmd>lua require('telescope').extensions.luasnip.luasnip()<cr>", desc = "snippets" },
      { "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "spelling suggestions" },
      { "<leader>sT", "<cmd>Telescope colorscheme<cr>", desc = "themes" },
      { "<leader>so", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
      { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "registers" },
      { "<leader>sl", "<cmd>Telescope marks<cr>", desc = "marks" },
      { "<leader>.", "<cmd>Telescope resume<cr>", desc = "resume last search" },

      -- projects
      { "<leader>pf", telescope_find_project_files, desc = "find project file" },
      { "<leader>pg", telescope_git_files, desc = "find git files" },
      { "<leader>sp", "<cmd>Telescope live_grep<cr>", desc = "search project for text" },
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

      -- load this lazy instead of with the projects plugin, because it does not depend on telescope, and we don't
      -- want to force telescope to load until it's needed
      telescope.load_extension("projects")
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "LukasPietzschmann/telescope-tabs",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      "benfowler/telescope-luasnip.nvim",
      {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
          require("telescope").load_extension("ui-select")
        end,
      },
    },
  },

  -- telescop project support
  {
    "ahmedkhalf/project.nvim",
    keys = {
      { "<leader>pp", telescope_load_projects, desc = "projects" },
    },
    lazy = false,
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
        show_hidden = false,
        datapath = vim.fn.stdpath("data"),
      })
    end,
  },
}
