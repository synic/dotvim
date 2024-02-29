require("ao.options")
local core = require("ao.core")

core.setup({
  guifont = "Hack:h11",
  theme = "rose-pine",
  projects_directory = os.getenv("HOME") .. "/Projects",
})
