local core = require("ao.core")

core.setup({
  guifont = "Hack:h10",
  theme = "gruvbox-material",
  projects_directory = os.getenv("HOME") .. "/Projects",
})
