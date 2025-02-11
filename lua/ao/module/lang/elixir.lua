local function sort_alias_block(args)
	local bufnr = args.buf

	local saved_view
	vim.api.nvim_buf_call(bufnr, function()
		saved_view = vim.fn.winsaveview()
	end)

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local alias_start = nil
	local alias_end = nil

	for i, line in ipairs(lines) do
		if line:match("[%s\t]*alias%s+[A-Z]") then
			if not alias_start then
				alias_start = i - 1
			end
			alias_end = i - 1
		elseif alias_start and not line:match("[%s\t]*alias%s+[A-Z]") then
			break
		end
	end

	if alias_start and alias_end and alias_end > alias_start then
		local alias_lines = vim.api.nvim_buf_get_lines(bufnr, alias_start, alias_end + 1, false)
		table.sort(alias_lines)
		vim.api.nvim_buf_set_lines(bufnr, alias_start, alias_end + 1, false, alias_lines)
	end

	vim.api.nvim_buf_call(bufnr, function()
		vim.fn.winrestview(saved_view)
	end)
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.ex", "*.exs" },
	callback = sort_alias_block,
	group = vim.api.nvim_create_augroup("ElixirAliasBlock", { clear = true }),
})

return {
	treesitter = { "elixir", "heex" },
	servers = {
		["nextls"] = function()
			require("lspconfig").nextls.setup({
				init_options = {
					experimental = {
						completions = { enable = true },
					},
				},
			})
		end,
	},
	plugins = {
		{
			"synic/refactorex.nvim",
			ft = "elixir",
			config = true,
		},
	},
}
