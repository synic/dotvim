return {
	treesitter = { "python" },
	servers = { "ruff", "pyright" },
	plugins = {
		{ "jmcantrell/vim-virtualenv", ft = "python" },
	},
	nonels = {
		"formatting.isort",
		"formatting.black",
	},
}
