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
		["elixirls"] = {
			cmd = { "elixir-ls" },
			filetypes = { "elixir", "eelixir", "heex", "surface" },
			root_dir = function(bufnr, on_dir)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = fname })
				local child_or_root_path, maybe_umbrella_path = unpack(matches)
				local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

				on_dir(root_dir)
			end,
		},
	},
	nonels = { "formatting.mix" },
	plugins = {
		{
			"synic/refactorex.nvim",
			ft = "elixir",
			config = true,
		},
	},
}
