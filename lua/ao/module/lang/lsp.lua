local config = require("ao.config")
local keymap = require("ao.keymap")
local tbl = require("ao.tbl")

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})
vim.api.nvim_set_hl(0, "LspProgressGrey", { fg = "#6b8fd1", blend = 40 })
vim.api.nvim_set_hl(0, "LspProgressGreyBold", { fg = "#6b8fd1", bold = true, blend = 40 })

---@type PluginModule
local M = {}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		require("ao.module.lang.progress").attach_progress()
		local picker = require("snacks").picker
		local buf = ev.buf
		local ft = vim.bo[buf].filetype

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
			{ "K", vim.lsp.buf.hover, desc = "Hover", buffer = buf },
		})

		if ft == "typescript" then
			keymap.add({
				{ "<localleader>o", "<cmd>TSToolsOrganizeImports", desc = "Organize imports" },
				{ "<localleader>f", "<cmd>TSToolsRenameFile<cr>", desc = "Rename file" },
			})
		end
	end,
})

M.plugin_specs = {
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
		event = "VeryLazy",
		opts = {
			ensure_installed = vim.list_extend(
				config.options.mason.ensure_installed_base,
				config.options.mason.ensure_installed
			),
			automatic_installation = true,
		},
		init = function()
			vim.filetype.add({ extension = { templ = "templ" } })
		end,
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")

			opts.handlers = {
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						settings = {
							Lua = {
								runtime = {
									version = "LuaJIT",
									path = { "?.lua", "?/init.lua", "lua/?.lua", "lua/?/init.lua" },
								},
								diagnostics = { globals = { "vim", "hs" } },
								completion = { callSnippet = "Replace", autoRequire = true, displayContext = 7 },
							},
						},
					})
				end,

				["htmx"] = function()
					lspconfig.htmx.setup({
						filetypes = { "html", "templ", "htmldjango" },
					})
				end,

				["nextls"] = function()
					lspconfig.nextls.setup({
						init_options = {
							experimental = {
								completions = { enable = true },
							},
						},
					})
				end,

				["tailwindcss"] = function()
					lspconfig.tailwindcss.setup({
						filetypes = {
							"templ",
							"astro",
							"javascript",
							"typescript",
							"react",
							"css",
							"html",
							"htmldjango",
						},
						init_options = { userLanguages = { templ = "html" } },
					})
				end,

				["rust_analyzer"] = function()
					lspconfig.rust_analyzer.setup({
						settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
								},
								checkOnSave = {
									allFeatures = true,
									command = "clippy",
								},
								procMacro = {
									ignored = {
										["async-trait"] = { "async_trait" },
										["napi-derive"] = { "napi" },
										["async-recursion"] = { "async_recursion" },
									},
								},
							},
						},
					})
				end,

				["templ"] = function()
					lspconfig.templ.setup({
						filetypes = { "templ" },
					})
				end,

				["ts_ls"] = function()
					lspconfig.ts_ls.setup({
						filetypes = { "templ", "javascript", "typescript", "html" },
					})
				end,

				["gopls"] = function()
					lspconfig.gopls.setup({
						settings = {
							gopls = {
								buildFlags = { "-tags=debug,release,mage,tools" },
								completeUnimported = true,
								analyses = {
									unusedparams = true,
								},
								hints = {
									rangeVariableTypes = true,
									parameterNames = true,
									constantValues = true,
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									functionTypeParameters = true,
								},
							},
						},
					})
				end,

				["emmet_language_server"] = function()
					lspconfig.emmet_language_server.setup({
						filetypes = {
							"css",
							"eruby",
							"html",
							"javascript",
							"javascriptreact",
							"htmldjango",
							"less",
							"sass",
							"scss",
							"svelte",
							"pug",
							"typescriptreact",
							"vue",
							"templ",
							"heex",
							"elixir",
						},
						init_options = {
							html = {
								options = {
									-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
									["bem.enabled"] = true,
								},
							},
						},
					})
				end,

				-- generic setup function for servers without explicit configuration
				function(server_name)
					server_name = server_name == "tsserver" and "ts_ls" or server_name -- fix weird tsserver naming situation
					require("lspconfig")[server_name].setup({})
				end,
			}

			mason_lspconfig.setup(opts)
		end,
	},

	-- lsp
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason-lspconfig.nvim",
		},
		event = "VeryLazy",
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

			defaults.capabilities = require("blink.cmp").get_lsp_capabilities()
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
		event = "VeryLazy",
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

			return {
				sources = {
					-- formatting
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.shfmt,
					null_ls.builtins.formatting.djhtml.with({
						"--tabwidth=2",
					}),
					null_ls.builtins.formatting.prettierd.with({
						filetypes = { "typescript", "javascript", "templ" },
					}),
					null_ls.builtins.formatting.prettier.with({
						filetypes = { "svelte" },
					}),
					null_ls.builtins.formatting.gofmt,
					null_ls.builtins.formatting.goimports_reviser,
					null_ls.builtins.formatting.golines,
					null_ls.builtins.formatting.isort,
					null_ls.builtins.formatting.black,
					null_ls.builtins.formatting.pg_format.with({
						extra_args = { "-s", "2", "-u", "1", "-w", "120" },
					}),
					null_ls.builtins.formatting.dart_format,
					-- ns.builtins.formatting.rustywind.with({
					-- 	filetypes = { "typescript", "javascript", "css", "templ", "html", "htmldjango" },
					-- }),

					require("none-ls.formatting.trim_whitespace"),

					-- diagnostics
					null_ls.builtins.diagnostics.gitlint,
					-- ns.builtins.diagnostics.mypy,
					null_ls.builtins.diagnostics.trail_space.with({
						disabled_filetypes = { "ctrlsf" },
					}),
					null_ls.builtins.diagnostics.yamllint,
					null_ls.builtins.diagnostics.hadolint, -- Dockerfile
					null_ls.builtins.diagnostics.markdownlint_cli2,
					null_ls.builtins.diagnostics.buf, -- protobuf
				},

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
}

return M
