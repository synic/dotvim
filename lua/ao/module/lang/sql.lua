return {
	treesitter = { "sql" },
	nonels = {
		["formatting.pg_format"] = {
			extra_args = { "-s", "2", "-u", "2", "-w", "120" },
		},
	},
}
