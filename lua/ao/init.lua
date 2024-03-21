local core = require("ao.core")

local config = {
  projects = {
    directory = os.getenv("HOME") .. "/Projects",
    root_names = { ".git", ".svn", ".project_root" },
  },
  appearance = {
    guifont = "Hack:h11",
    theme = "duskfox",
  },
}

local ok, local_config = pcall(require, "local_config")
if ok then
  config = vim.tbl_deep_extend("force", config, local_config)
end

core.setup(config)
