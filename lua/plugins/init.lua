local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup({
	function(use)
		-- package manager
		use("wbthomason/packer.nvim")

		-- python
		use("hynek/vim-python-pep8-indent")
		use("python-mode/python-mode")

		-- project management
		use("ibhagwan/fzf-lua")
		use("dbakker/vim-projectroot")
		use("kien/ctrlp.vim")
		use("d11wtq/ctrlp_bdelete.vim")
		use({
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
		})
		use({
			"nvim-telescope/telescope-fzf-native.nvim",
			run = "make",
		})
		use({
			"ahmedkhalf/project.nvim",
			config = function()
				require("project_nvim").setup({})

				local status, telescope = pcall(require, "telescope")
				if not status then
					return
				end

				telescope.load_extension("projects")
			end,
		})

		-- copying/editing
		use("neovim/nvim-lspconfig")
		use("onsails/lspkind-nvim")
		use("L3MON4D3/LuaSnip")
		use("hrsh7th/cmp-nvim-lsp")
		use("hrsh7th/cmp-buffer")
		use("hrsh7th/nvim-cmp")
		use("SirVer/ultisnips")
		use("honza/vim-snippets")
		use("tpope/vim-surround")
		use("w0rp/ale")
		use("jmcantrell/vim-virtualenv")
		use("editorconfig/editorconfig-vim")
		use("tpope/vim-commentary")
		use({
			"smjonas/inc-rename.nvim",
			config = function()
				require("inc_rename").setup()
			end,
		})
		use({
			"folke/trouble.nvim",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("trouble").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})

		-- formatting
		use("ntpeters/vim-better-whitespace")
		use("mhartington/formatter.nvim")

		-- search
		use("dyng/ctrlsf.vim")
		use("haya14busa/incsearch.vim")

		-- syntax files
		use("plasticboy/vim-markdown")
		use("ap/vim-css-color")
		use("pangloss/vim-javascript")

		-- undo
		use("sjl/gundo.vim")

		-- git
		use("mattn/webapi-vim")
		use("mattn/gist-vim")
		use("tpope/vim-fugitive")
		use("airblade/vim-gitgutter")
		use("gregsexton/gitv")
		use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })

		-- movement
		use("Lokaltog/vim-easymotion")
		use("vim-scripts/quit-another-window")

		-- colorschemes
		use("synic/jellybeans.vim")
		use("jnurmine/Zenburn")
		use("morhetz/gruvbox")
		use("synic/synic.vim")

		-- interface
		use("bling/vim-airline")

		-- misc
		use("vim-scripts/openssl.vim")
		use("Valloric/ListToggle")
		use("ConradIrwin/vim-bracketed-paste")

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
require("functions").glob_require("plugins")
