return function(use)
	use("editorconfig/editorconfig-vim")
	use("tpope/vim-surround")
	use({
		"tpope/vim-commentary",
		config = function()
			vim.cmd([[
				function! ToggleComment()
					if mode() !~# "^[vV\<C-v>]"
						" not visual mode
						normal gcc
  				else
						visual gc
					endif
				endfunction

				:nmap <space>cl :call ToggleComment()<cr>
				:vmap <space>cl :call ToggleComment()<cr>
		]])
		end,
	})
	use({
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<space>tu", ":UndotreeToggle<cr>")
		end,
	})

	use({
		"p00f/nvim-ts-rainbow",
		requires = "nvim-treesitter/nvim-treesitter",
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_end_of_line = true,
			})

			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
	})

	-- snippets
	use({
		"L3MON4D3/LuaSnip",
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { "~/.config/nvim/snippets/" },
			})
		end,
	})

	-- openai
	use({
		"madox2/vim-ai",
		run = "./install.sh",
		config = function()
			local function ai_prompt()
				local phrase = vim.fn.input("Prompt for AI: ")
				vim.cmd(":AI " .. phrase)
			end

			vim.keymap.set("n", "<space>ac", ":AIChat<cr>")
			vim.keymap.set("v", "<space>ae", function()
				return ":AIEdit " .. vim.fn.input("Prompt for AI: ") .. "<cr>"
			end, { expr = true })
			vim.keymap.set("n", "<space>ai", ai_prompt)
		end,
	})
end
