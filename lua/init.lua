local f = require("core.functions")

local packer_bootstrap = f.ensure_packer()

require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim")

		require("modules.python")(use)
		require("modules.project")(use)
		require("modules.language")(use)
		require("modules.formatting")(use)
		require("modules.git")(use)
		require("modules.search")(use)
		require("modules.motion")(use)
		require("modules.syntax")(use)
		require("modules.themes")(use)
		require("modules.editing")(use)
		require("modules.misc")(use)
		require("modules.interface")(use)

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = require("packer.util").float,
		},
	},
})
