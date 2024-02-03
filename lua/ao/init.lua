local core = require("ao.core")

core.setup({
  guifont = "Hack:h10.5",
  theme = "catppuccin",
  projects_directory = os.getenv("HOME") .. "/Projects",
})
