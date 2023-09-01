return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "dart" })
			end
		end,
	},
	{ "dart-lang/dart-vim-plugin", ft = "dart" },
}
