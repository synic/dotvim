local utils = require("ao.utils")

local function telescope_grep_project_for_term()
  local builtin = require("telescope.builtin")
  local current_word = vim.fn.expand("<cword>")
  local project_root = utils.find_project_root()

  builtin.grep_string({
    cwd = (project_root or "."),
    search = current_word,
  })
end

local telescope_tabs_entry_formatter = function(tab_id, _, file_names, _, is_current)
  local status, name = pcall(vim.api.nvim_tabpage_get_var, tab_id, "ao-tab-name")
  local display = "[No Name]"

  if status and name ~= nil then
    display = name
  else
    local entry_string = table.concat(file_names, ", ")
    if entry_string == "" then
      entry_string = "[No Name]"
    end
    display = entry_string
  end
  return string.format("%d: %s%s", tab_id, display, is_current and " <" or "")
end

local function telescope_grep_working_directory()
  local builtin = require("telescope.builtin")
  builtin.live_grep({ cwd = vim.fn.expand("%:p:h") })
end

local function ctrlsf_search_for_term(prompt_bufnr)
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local prompt = current_picker:_get_prompt()
  vim.cmd.CtrlSF(prompt)
end

local function telescope_load_projects()
  local noun = require("noun")

  if #noun.get_recent_projects() == 0 then
    vim.notify("No projects found", vim.log.levels.WARN)
    return
  end

  require("telescope").extensions.noun.noun({ layout_config = { width = 0.45, height = 0.4 } })
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

  local project_root = utils.find_project_root()
  if project_root and project_root ~= "" then
    builtin.find_files({ cwd = project_root })
  else
    vim.notify("No project root was found, listing projects...")
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

local function telescope_show_tabs()
  require("telescope").extensions["telescope-tabs"].list_tabs({
    layout_config = { width = 0.4, height = 0.3 },
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
      { "<leader>ll", telescope_show_tabs, desc = "List layouts" },

      -- search
      {
        "<leader>*",
        telescope_grep_project_for_term,
        desc = "Search for term in project",
        mode = { "n", "v" },
      },
      {
        "<leader>sd",
        telescope_grep_working_directory,
        desc = "Search in current directory",
      },
      { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
      { "<leader>sS", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
      { "<leader>sT", "<cmd>Telescope colorscheme<cr>", desc = "Themes" },
      { "<leader>,", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sl", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>sb", "<cmd>Telescope builtin<cr>", desc = "List pickers" },

      -- undo
      { "<leader>tu", "<cmd>Telescope undo<cr>", desc = "Undo tree" },

      -- projects
      { "<leader>pf", telescope_find_project_files, desc = "Find project file" },
      { "<leader>pg", telescope_git_files, desc = "Find git files" },
      { "<leader>pp", telescope_load_projects, desc = "Projects" },
      { "<leader>pa", "<cmd>AddProject<cr>", desc = "Add project to projects list" },
      {
        "<leader>sp",
        "<cmd>Telescope live_grep<cr>",
        desc = "Search project for text",
      },
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
          ["telescope-tabs"] = {
            prompt_title = "Layouts",
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
        "debugloop/telescope-undo.nvim",
        config = function()
          utils.on_load("telescope.nvim", function()
            require("telescope").load_extension("undo")
          end)
        end,
      },
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
        config = function()
          utils.on_load("telescope.nvim", function()
            require("telescope").load_extension("fzf")
          end)
        end,
      },
      {
        "synic/noun.nvim",
        opts = {
          manual_mode = true,
          silent_chdir = true,
          detection_methods = { "pattern", "lsp" },
          -- has to be global, there's some weird interaction between telescope and `:tcd`/`:lcd` that will sometimes cause
          -- the first file that you open after selecting a project to be blank
          scope_chdir = "global",
          patterns = { ".git", ".svn" },
          exclude_dirs = { "node_modules" },
          project_selected_callback_fn = function(path)
            local tabnr = vim.fn.tabpagenr()
            local status, _ = pcall(vim.api.nvim_tabpage_get_var, tabnr, "ao-tab-name")

            if status then
              return false
            end

            vim.api.nvim_tabpage_set_var(tabnr, "ao-tab-name", vim.fn.fnamemodify(path, ":t"))

            return false
          end,
          pattern_get_current_dir_fn = function()
            local status, oil = pcall(require, "oil")

            if status then
              local dir = oil.get_current_dir()

              if dir ~= nil then
                return dir
              end
            end
            return vim.fn.expand("%:p:h", true)
          end,
          show_hidden = false,
          datapath = vim.fn.stdpath("data"),
        },
        config = function(_, opts)
          utils.on_load("telescope.nvim", function()
            require("telescope").load_extension("noun")
          end)
          require("noun").setup(opts)
        end,
      },
    },
  },
}
