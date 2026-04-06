local clear_winbar_group = vim.api.nvim_create_augroup("WinBarHlClearBg", { clear = true })
vim.pack.add({ "https://github.com/Bekaboo/dropbar.nvim" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local dutils = require("dropbar.utils")
		local preview = false
		local ignore = { "gitcommit" }
		local include = { "oil" }

		---Set WinBar & WinBarNC background to Normal background
		local function clear_winbar_bg()
			---@param name string
			local function _clear_bg(name)
				local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
				if hl.bg or hl.ctermbg then
					---@diagnostic disable-next-line: inject-field
					hl.bg = nil
					---@diagnostic disable-next-line: undefined-field, inject-field
					hl.ctermbg = nil
					---@diagnostic disable-next-line: param-type-mismatch
					vim.api.nvim_set_hl(0, name, hl)
				end
			end

			_clear_bg("WinBar")
			_clear_bg("WinBarNC")
		end

		clear_winbar_bg()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = clear_winbar_group,
			callback = clear_winbar_bg,
		})

		require("dropbar").setup({
			bar = {
				enable = function(buf, win)
					if vim.tbl_contains(include, vim.bo[buf].filetype) then
						return true
					end

					return vim.fn.win_gettype(win) == ""
						and vim.wo[win].winbar == ""
						and vim.bo[buf].bt == ""
						and not vim.tbl_contains(ignore, vim.bo[buf].ft)
						and (
							vim.bo[buf].ft == "markdown"
							or (
								buf
									and vim.api.nvim_buf_is_valid(buf)
									and (pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft))
									and true
								or false
							)
						)
				end,
			},
			menu = {
				preview = preview,
				keymaps = {
					["q"] = "<C-w>q",
					["h"] = "<C-w>q",
					["<LeftMouse>"] = function()
						local menu = dutils.menu.get_current()
						if not menu then
							return
						end
						local mouse = vim.fn.getmousepos()
						---@diagnostic disable-next-line: undefined-field
						local clicked_menu = dutils.menu.get({ win = mouse.winid })
						-- If clicked on a menu, invoke the corresponding click action,
						-- else close all menus and set the cursor to the clicked window
						if clicked_menu then
							clicked_menu:click_at({
								---@diagnostic disable-next-line: undefined-field
								mouse.line,
								---@diagnostic disable-next-line: undefined-field
								mouse.column - 1,
							}, nil, 1, "l")
							return
						end
						dutils.menu.exec("close")
						dutils.bar.exec("update_current_context_hl")
						---@diagnostic disable-next-line: undefined-field
						if vim.api.nvim_win_is_valid(mouse.winid) then
							---@diagnostic disable-next-line: undefined-field
							vim.api.nvim_set_current_win(mouse.winid)
						end
					end,
					["l"] = function()
						local menu = dutils.menu.get_current()
						if not menu then
							return
						end
						local cursor = vim.api.nvim_win_get_cursor(menu.win)
						local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
						if component then
							menu:click_on(component, nil, 1, "l")
						end
					end,
					["<MouseMove>"] = function()
						local menu = dutils.menu.get_current()
						if not menu then
							return
						end
						local mouse = vim.fn.getmousepos()
						dutils.menu.update_hover_hl(mouse)
						if preview then
							dutils.menu.update_preview(mouse)
						end
					end,
					["i"] = function()
						local menu = dutils.menu.get_current()
						if not menu then
							return
						end
						menu:fuzzy_find_open()
					end,
				},
			},
		})
	end,
})
