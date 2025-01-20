return {
	treesitter = { "sql" },
	nonels = {
		["formatting.pg_format"] = {
			extra_args = { "-s", "2", "-u", "1", "-w", "120" },
		},
	},
}
