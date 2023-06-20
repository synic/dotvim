vim.api.nvim_set_option("guifont", "Hack:h10")

-- neovide options
vim.g.neovide_remember_window_size = false
vim.g.neovide_remember_window_position = false

local f = require("core.functions")
local packer_bootstrap = f.ensure_packer()

require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim")

		require("modules.projects")(use)
		require("modules.language")(use)
		require("modules.formatting")(use)
		require("modules.completion")(use)
		require("modules.filesystem")(use)
		require("modules.vcs")(use)
		require("modules.search")(use)
		require("modules.motion")(use)
		require("modules.themes")(use)
		require("modules.editing")(use)
		require("modules.debugging")(use)
		require("modules.utils")(use)
		require("modules.interface")(use)

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
})
