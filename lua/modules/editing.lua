return {
	"editorconfig/editorconfig-vim",
	"tpope/vim-surround",
	{
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
	},
	{
		"mbbill/undotree",
		lazy = true,
		keys = { "<space>tu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
	},

	{
		"p00f/nvim-ts-rainbow",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_end_of_line = true,
			})

			vim.opt.list = true
			vim.opt.listchars:append("eol:↴")
		end,
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { "~/.config/nvim/snippets/" },
			})
		end,
	},
	-- openai
	{
		"madox2/vim-ai",
		build = "./install.sh",
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
	},
}
