local utils = require("ao.utils")
local keymap = require("ao.keymap")

local module = {}

module.search_star = function()
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

module.search_cwd = function()
  local builtin = require("telescope.builtin")
  builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

module.search_for_term = function(prompt_bufnr)
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local prompt = current_picker:_get_prompt()
  vim.cmd(":CtrlSF " .. prompt)
end

module.load_projects = function()
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

module.git_files = function()
  local util = require("telescope.utils")
  local builtin = require("telescope.builtin")

  local _, ret, _ = util.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
  if ret == 0 then
    builtin.git_files()
  else
    module.load_projects()
  end
end

module.find_project_files = function()
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
    module.load_projects()
  end
end

module.new_tab_with_projects = function()
  vim.cmd(":tabnew<cr>")
  module.load_projects()
end

module.search_buffers = function()
  require("telescope.builtin").buffers({
    sort_mru = true,
    sort_lastused = true,
    icnore_current_buffer = true,
  })
end

return utils.table_concat(module, {
  {
    "nvim-telescope/telescope.nvim",
    keys = keymap.telescope,
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
                ["<C-e>"] = module.search_for_term,
              },
            },
          },
          grep_string = {
            mappings = {
              i = {
                ["<C-e>"] = module.search_for_term,
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

  {
    "ahmedkhalf/project.nvim",
    keys = keymap.project,
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
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data"),
      })
    end,
  },
})
