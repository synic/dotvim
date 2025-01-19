local M = {
	progress_attached = false,
}

M.attach_progress = function()
	if M.progress_attached then
		return
	end

	M.progress_attached = true
	local _, has_snacks = pcall(require, "snacks")
	if not has_snacks then
		return
	end
	local max_width = 40

	---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
	local progress = vim.defaulttable()
	vim.api.nvim_create_autocmd("LspProgress", {
		---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
			if not client or type(value) ~= "table" then
				return
			end
			local p = progress[client.id]

			for i = 1, #p + 1 do
				if i == #p + 1 or p[i].token == ev.data.params.token then
					p[i] = {
						token = ev.data.params.token,
						msg = ("%3d%% %s%s"):format(
							value.kind == "end" and 100 or value.percentage or 100,
							value.title or "",
							value.message and (" %s"):format(value.message) or ""
						),
						done = value.kind == "end",
					}
					break
				end
			end

			local msg = {} ---@type string[]
			progress[client.id] = vim.tbl_filter(function(v)
				local line = v.msg
				if #line > max_width then
					local cutoff = max_width - 3
					while cutoff > 1 and line:sub(cutoff, cutoff) ~= " " do
						cutoff = cutoff - 1
					end
					line = line:sub(1, cutoff) .. "..."
					line = line .. string.rep(" ", max_width - #line)
				else
					line = line .. string.rep(" ", max_width - #line)
				end
				return table.insert(msg, line) or not v.done
			end, p)

			local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
			vim.notify(table.concat(msg, "\n"), "info", {
				id = "lsp_progress",
				title = client.name,
				timeout = 1200,
				level = 0,
				width = { min = 50, max = 50 },
				opts = function(notif)
					---@diagnostic disable-next-line: missing-fields
					notif.hl = {
						icon = "LspProgressGreyBold",
						title = "LspProgressGreyBold",
						border = "LspProgressGrey",
						footer = "LspProgressGrey",
						msg = "LspProgressGrey",
					}
					notif.icon = #progress[client.id] == 0 and " "
						or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
				end,
			})
		end,
	})
end

M._plugin_specs = { -- currently disabled
	{
		"j-hui/fidget.nvim",
		opts = {
			progress = {
				suppress_on_insert = true,
				ignore_done_already = false,
				ignore_empty_message = true,
				display = {
					group_style = "LspProgressGrey",
					icon_style = "LspProgressGrey",
					done_style = "LspProgressGrey",
					done_ttl = 1,
					render_limit = 1,
				},
			},
			notification = {
				window = {
					normal_hl = "LspProgressGrey",
					max_width = 100,
					max_height = 3,
				},
			},
		},
	},
}

return M
