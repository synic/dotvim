vim.o.shada = "!,'20,<50,s10,h"

return {
  options = {
    projects = {
      directory = os.getenv("HOME") .. "/Projects",
      root_names = { ".git", ".svn", ".project_root" },
    },

    appearance = {
      guifont = "Hack:h11",
      theme = "duskfox",
    },

    lazy = {
      install = { install_missing = false },
      change_detection = {
        -- with change detection enabled, lazy.nvim does something when you save
        -- lua files that are modules. whatever it does, it wipes out the none-ls
        -- autocmd that is set up to format on save. It also causes other events to
        -- attach more than once (gitsigns). better to just leave it off.
        enabled = false,
        notify = false,
      },
    },
  },
}