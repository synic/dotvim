local config = require("ao.config")
local utils = require("ao.utils")
local interface = require("ao.modules.interface")
local projects = require("ao.modules.projects")

local M = {}

local function telescope_search_project_cursor_term()
  local builtin = require("telescope.builtin")
  local current_word = vim.fn.expand("<cword>")
  local root = projects.find_buffer_root()

  builtin.grep_string({ cwd = (root or "."), search = current_word })
end

local function telescope_narrow_grep(prompt_bufnr)
  local builtin = require("telescope.builtin")
  local actions = require("telescope.actions")
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)

  local root = projects.find_buffer_root()
  local prompt = current_picker:_get_prompt()
  actions.close(prompt_bufnr)

  if not prompt or prompt == "" then
    vim.notify("no prompt to narrow", vim.log.levels.WARN)
    return
  end

  vim.notify('narrowing to: "' .. prompt .. '"')

  builtin.grep_string({ cwd = (root or "."), search = prompt, default_text = prompt })
end

local telescope_tabs_entry_formatter = function(tabnr, _, _, _, is_current)
  local name = interface.get_tab_name(tabnr)
  local display = "[No Name]"

  if name and name ~= "" then
    display = name
  else
    display = require("tabby.feature.tab_name").get(tabnr)
  end

  if vim.fn.gettabvar(tabnr, "projectset") == true then
    display = "project: " .. display
  end

  return string.format("%d: %s%s", tabnr, display, is_current and " <" or "")
end

local function telescope_search_cwd()
  require("telescope.builtin").live_grep({ cwd = utils.get_buffer_cwd() })
end

local function telescope_find_files_cwd()
  require("telescope.builtin").find_files({ cwd = utils.get_buffer_cwd() })
end

local function ctrlsf_search_for_term(prompt_bufnr)
  local actions = require("telescope.actions")
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)

  local prompt = current_picker:_get_prompt()
  actions.close(prompt_bufnr)
  if not prompt then
    vim.notify("Edit: no search terms", vim.log.levels.WARN)
    return
  end
  vim.cmd.CtrlSF(prompt)
end

local function dirpicker_pick_project(cb)
  local telescope_config = require("telescope.config").values
  require("telescope").extensions.dirpicker.dirpicker({
    cwd = config.options.projects.directory or ".",
    layout_config = { width = 0.45, height = 0.4, preview_width = 0.5 },
    prompt_title = "Projects",
    sorter = telescope_config.generic_sorter({}),
    on_select = cb,
  })
end

local function telescope_pick_project()
  dirpicker_pick_project(projects.open)
end

local function telescope_switch_project()
  vim.t.projectset = false
  telescope_pick_project()
end

local function telescope_git_files()
  local builtin = require("telescope.builtin")

  local root = projects.find_buffer_root()
  if root and root ~= "" then
    builtin.git_files({ cwd = root })
  else
    vim.notify("Project: no project selected", vim.log.levels.INFO)
    telescope_pick_project()
  end
end

local function telescope_search_project()
  local builtin = require("telescope.builtin")
  builtin.live_grep({ cwd = (projects.find_buffer_root() or ".") })
end

local function telescope_find_project_files()
  local builtin = require("telescope.builtin")

  local root = projects.find_buffer_root()
  if root and root ~= "" then
    builtin.find_files({ cwd = root })
  else
    vim.notify("Project: no project selected", vim.log.levels.INFO)
    telescope_pick_project()
  end
end

local function telescope_new_tab_with_project()
  dirpicker_pick_project(function(dir)
    vim.cmd.tabnew()
    projects.open(dir)
  end)
end

local function telescope_goto_project()
  vim.cmd.Oil(vim.fn.getcwd(-1, 0))
end

local function telescope_set_project()
  local root = projects.find_buffer_root()
  if root and root ~= "" then
    projects.set(root)
  end
end

M.plugin_specs = {
  -- fuzzy finder and list manager
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- layouts/windows
      { "<leader>lt", telescope_new_tab_with_project, desc = "New layout with project" },
      { "<leader>ll", "<cmd>Telescope telescope-tabs list_tabs<cr>", desc = "List layouts" },

      -- search
      { "<leader>*", telescope_search_project_cursor_term, desc = "Search project for term", mode = { "n", "v" } },
      { "<leader>sd", telescope_search_cwd, desc = "Search in buffer's directory" },
      { "<leader>sp", telescope_search_project, desc = "Search project for text" },
      { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
      { "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
      { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sl", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>sB", "<cmd>Telescope builtin<cr>", desc = "List pickers" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },
      { "<leader>sn", "<cmd>Telescope notify<cr>", desc = "Notifications" },
      { "<leader>.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>,", "<cmd>Telescope recent_files pick<cr>", desc = "Recent files" },

      -- buffers
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Show buffers" },
      { "<leader>bs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search buffer" },

      -- files
      { "<leader>ff", telescope_find_files_cwd, desc = "Find files" },
      { "<leader>fr", "<cmd>Telescope recent_files pick<cr>", desc = "Recent files" },
      { "<leader>fs", telescope_search_cwd, desc = "Search files" },

      -- themes
      { "<leader>st", "<cmd>ColorSchemePicker<cr>", desc = "List themes" },

      -- undo
      { "<leader>tu", "<cmd>Telescope undo<cr>", desc = "Undo tree" },

      -- projects
      { "<leader>p/", telescope_search_project, desc = "Search project for text" },
      { "<leader>pf", telescope_find_project_files, desc = "Find project file" },
      { "<leader>pg", telescope_git_files, desc = "Find git files" },
      { "<leader>pp", telescope_pick_project, desc = "Pick project" },
      { "<leader>pP", telescope_switch_project, desc = "Switch project" },
      { "<leader>ph", telescope_goto_project, desc = "Go to project home" },
      { "<leader>pS", telescope_set_project, desc = "Set project home" },
    },
    cmd = "Telescope",
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
              ["//"] = actions.file_vsplit,
              ["--"] = actions.file_split,
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
          ["telescope-tabs"] = {
            prompt_title = "Layouts",
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
            layout_config = {
              preview_width = 0.55,
            },
          },
          live_grep = {
            mappings = {
              i = {
                ["<C-e>"] = ctrlsf_search_for_term,
                ["<C-;>"] = telescope_narrow_grep,
              },
              n = {
                ["e"] = ctrlsf_search_for_term,
                [";"] = telescope_narrow_grep,
              },
            },
          },
          grep_string = {
            mappings = {
              i = {
                ["<C-e>"] = ctrlsf_search_for_term,
              },
              n = {
                ["e"] = ctrlsf_search_for_term,
              },
            },
            layout_config = {
              preview_width = 0.5,
            },
          },
          colorscheme = {
            enable_preview = true,
          },
          find_files = {
            layout_config = {
              preview_width = 0.55,
            },
          },
          ["telescope-tabs"] = {
            layout_config = { width = 0.4, height = 0.3 },
          },
        },
      })

      telescope.load_extension("ui-select")
      telescope.load_extension("fzf")
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "benfowler/telescope-luasnip.nvim",
      "synic/telescope-dirpicker.nvim",
      "smartpde/telescope-recent-files",
      "debugloop/telescope-undo.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      {
        "LukasPietzschmann/telescope-tabs",
        opts = {
          entry_formatter = telescope_tabs_entry_formatter,
          entry_ordinal = telescope_tabs_entry_formatter,
          show_preview = false,
        },
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
    },
  },
}

return M
