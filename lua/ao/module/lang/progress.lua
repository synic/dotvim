local update_delay_ms = 300

local last_update = 0
vim.api.nvim_set_hl(0, "LspProgressGrey", { fg = "#7a89b8", blend = 40 })
vim.api.nvim_set_hl(0, "LspProgressGreyBold", { fg = "#7a89b8", bold = true, blend = 40 })

local function is_blocking()
	local mode = vim.api.nvim_get_mode()
	for _, m in ipairs({ "ic", "ix", "c", "no", "r%?", "rm" }) do
		if mode.mode:find(m) == 1 then
			return true
		end
	end
	return mode.blocking
end

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
		local current_time = vim.uv.now()
		if is_blocking() or (current_time - last_update) < update_delay_ms then
			return
		end
		last_update = current_time

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

		local last_three = {}
		for i = math.max(1, #msg - 2), #msg do
			if not vim.tbl_contains(last_three, msg[i]) then
				table.insert(last_three, msg[i])
			end
		end

		vim.notify(table.concat(last_three, "\n"), "info", {
			id = "lsp_progress",
			title = client.name,
			timeout = 1200,
			level = 5000,
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

return {}
