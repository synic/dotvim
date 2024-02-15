local core = require("ao.core")

core.setup({
  guifont = "Hack:h11",
  theme = "catppuccin",
  projects_directory = os.getenv("HOME") .. "/Projects",
})
