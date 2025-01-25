local keymap = require("ao.keymap")
local tbl = require("ao.tbl")

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})

---@type PluginModule
local M = {}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local picker = require("snacks").picker
		local buf = ev.buf
		local ft = vim.bo[buf].filetype

		local function hover()
			local width = math.floor(vim.o.columns * 0.8)
			local height = math.floor(vim.o.lines * 0.3)

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				max_width = width,
				max_height = height,
			})

			vim.lsp.buf.hover()
		end

		keymap.add({
			{ "<localleader>r", vim.lsp.buf.rename, desc = "Rename symbol", buffer = buf },
			{ "<localleader>,", vim.lsp.buf.code_action, desc = "Code actions", buffer = buf, mode = { "n", "v" } },
			{ "<localleader>=", vim.lsp.buf.format, desc = "Format document", buffer = buf, mode = { "n", "v" } },
			{ "<localleader>^", "<cmd>LspRestart<cr>", desc = "Restart LSP", buffer = buf },
			{ "<localleader>$", "<cmd>LspInfo<cr>", desc = "LSP Info", buffer = buf },
			{ "=", vim.lsp.buf.format, desc = "Format selection", buffer = buf, mode = { "v" } },

			{ "gd", picker.lsp_definitions, desc = "Definition(s)", buffer = buf },
			{ "gD", vim.lsp.buf.declaration, desc = "Declaration(s)", buffer = buf },
			{
				"g/",
				"<cmd>vsplit<cr><cmd>lua require('snacks').picker.lsp_definitions()<cr>",
				desc = "Goto def in vsplit",
				buffer = buf,
			},
			{
				"g-",
				"<cmd>split<cr><cmd>lua require('snacks').picker.lsp_definitions()<cr>",
				desc = "Goto def in hsplit",
				buffer = buf,
			},
			{ "grr", picker.lsp_references, desc = "Reference(s)", buffer = buf },
			{ "gri", picker.lsp_implementations, desc = "Implementation(s)", buffer = buf },
			{ "g.", picker.lsp_symbols, desc = "Document symbols", buffer = buf },
			{ "K", hover, desc = "Hover", buffer = buf },
		})

		if ft == "typescript" then
			keymap.add({
				{ "<localleader>o", "<cmd>TSToolsOrganizeImports", desc = "Organize imports" },
				{ "<localleader>f", "<cmd>TSToolsRenameFile<cr>", desc = "Rename file" },
			})
		end
	end,
})

M.get_plugins = function(langs, servers, handlers, nonels)
	table.insert(handlers, function(server_name)
		server_name = server_name == "tsserver" and "ts_ls" or server_name -- fix weird tsserver naming situation
		require("lspconfig")[server_name].setup({})
	end)
	return {
		{
			"williamboman/mason.nvim",
			config = true,
			lazy = false, -- mason does not like to be lazy loaded
			keys = {
				{ "<leader>cM", "<cmd>Mason<cr>", desc = "Mason" },
			},
		},

		{
			"williamboman/mason-lspconfig.nvim",
			ft = langs,
			cmd = "Mason",
			opts = {
				ensure_installed = servers,
				automatic_installation = true,
				handlers = handlers,
			},
		},

		-- lsp
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				-- "saghen/blink.cmp",
				"williamboman/mason-lspconfig.nvim",
				"hrsh7th/nvim-cmp",
			},
			ft = langs,
			cmd = "Mason",
			opts = {
				diagnostic = {
					underline = true,
					update_in_insert = false,
					inlay_hints = true,
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
					},
					severity_sort = true,
				},
			},
			config = function(_, opts)
				local lspconfig = require("lspconfig")
				local defaults = lspconfig.util.default_config

				vim.diagnostic.config(opts.diagnostic)

				vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
					side_padding = 1,
					border = "rounded",
					winhighlight = "CursorLine:CursorLine,Normal:Normal",
				})
				vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
					side_padding = 1,
					border = "rounded",
					winhighlight = "CursorLine:CursorLine,Normal:Normal",
				})

				local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
				end

				-- defaults.capabilities = require("blink.cmp").get_lsp_capabilities()
				defaults.capabilities = require("cmp_nvim_lsp").default_capabilities()
			end,
		},

		-- diagnostics and formatting
		{
			"nvimtools/none-ls.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"davidmh/cspell.nvim",
				"nvimtools/none-ls-extras.nvim",
			},
			ft = langs,
			opts = function()
				local null_ls = require("null-ls")

				-- only use none-ls for formatting these filetypes; the rest can use any formatter
				local only_nonels_formatting_filetypes = {
					"lua",
					"typescript",
					"javascript",
					"go",
					"svelte",
				}

				local sources = {}

				for source, args in pairs(nonels) do
					if type(source) == "number" then
						table.insert(sources, require("null-ls.builtins." .. args))
					else
						table.insert(sources, require("null-ls.builtins." .. source).with(args))
					end
				end

				return {
					sources = tbl.concat({
						require("none-ls.formatting.trim_whitespace"),
						null_ls.builtins.diagnostics.trail_space,
					}, sources),

					on_attach = function(client, bufnr)
						local ft = vim.bo[bufnr].filetype
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_clear_autocmds({ group = lsp_formatting_group, buffer = bufnr })
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = lsp_formatting_group,
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({
										bufnr = bufnr,
										timeout = 4000,
										filter = function(c)
											if tbl.contains(only_nonels_formatting_filetypes, ft) then
												return c.name == "null-ls"
											end
											return true
										end,
									})
								end,
							})
						end
					end,
				}
			end,
		},

		-- to show lsp progress
		{
			"j-hui/fidget.nvim",
			event = "LspAttach",
			opts = {
				notification = {
					window = {
						winblend = 20,
					},
				},
				progress = {
					suppress_on_insert = true,
					ignore_done_already = false,
					ignore_empty_message = true,
					display = {
						done_ttl = 1,
						skip_history = false,
						format_message = function(msg)
							local message = msg.message

							if not message then
								message = msg.done and "Completed" or "In progress..."
							end
							if msg.percentage ~= nil then
								message = string.format("%s (%.0f%%)", message, msg.percentage)
							end

							-- hack to supress long messages nextls sometimes outputs
							if msg.lsp_client.config.name == "nextls" then
								message = message:gsub("for folder", "for")
								message = message:gsub("[%w%-%._/\\]+/([%w%-%._]+)[%p]?", "%1")
								message = message:gsub("\\[%w%-%._/\\]+\\([%w%-%._]+)[%p]?", "%1")
							end

							return message
						end,
						format_annote = function(msg)
							local annote = msg.title

							if not annote then
								return nil
							end

							-- hack to supress long messages nextls sometimes outputs
							if msg.lsp_client.config.name == "nextls" and msg.done then
								return ""
							end
							return annote
						end,
					},
				},
			},
		},
	}
end

return M
