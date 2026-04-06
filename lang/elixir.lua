return {
	treesitter = { "elixir", "heex" },
	servers = {
		expert = {
			-- using `just release` in the expert HEAD, which puts the binary in ~/.local/bin
			use_mason = false,
		},
	},
}
