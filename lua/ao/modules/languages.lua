local config = require("ao.config")
local utils = require("ao.utils")

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})

local M = {}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local picker = require("snacks").picker
		local bufnr = ev.buf
		local ft = vim.bo[bufnr].filetype

		utils.map_keys({
			{ "<localleader>r", vim.lsp.buf.rename, desc = "Rename symbol", buffer = bufnr },
			{ "<localleader>,", vim.lsp.buf.code_action, desc = "Code actions", buffer = bufnr, mode = { "n", "v" } },
			{ "<localleader>=", vim.lsp.buf.format, desc = "Format document", buffer = bufnr, mode = { "n", "v" } },
			{ "<localleader>^", "<cmd>LspRestart<cr>", desc = "Restart LSP", buffer = bufnr },
			{ "<localleader>$", "<cmd>LspInfo<cr>", desc = "LSP Info", buffer = bufnr },
			{ "=", vim.lsp.buf.format, desc = "Format selection", buffer = bufnr, mode = { "v" } },

			{ "gd", picker.lsp_definitions, desc = "Definition(s)", buffer = bufnr },
			{ "gD", vim.lsp.buf.declaration, desc = "Declaration(s)", buffer = bufnr },
			{
				"g/",
				"<cmd>vsplit<cr><cmd>lua require('snacks').picker.lsp_definitions()<cr>",
				desc = "Goto def in vsplit",
				buffer = bufnr,
			},
			{
				"g-",
				"<cmd>split<cr><cmd>lua require('snacks').picker.lsp_definitions()<cr>",
				desc = "Goto def in hsplit",
				buffer = bufnr,
			},
			{ "grr", picker.lsp_references, desc = "Reference(s)", buffer = bufnr },
			{ "gri", picker.lsp_implementations, desc = "Implementation(s)", buffer = bufnr },
			{ "g.", picker.lsp_symbols, desc = "Document symbols", buffer = bufnr },
			{ "K", vim.lsp.buf.hover, desc = "Hover", buffer = bufnr },
		})

		if ft == "typescript" then
			utils.map_keys({
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
		"synic/refactorex.nvim",
		ft = "elixir",
		config = true,
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

	-- neovim development
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
				{ path = "lazy.nvim", words = { "LazyVim" } },
			},
		},
	},

	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = true,
	},

	-- lsp
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/nvim-cmp",
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

			defaults.capabilities =
				vim.tbl_deep_extend("force", defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())
			-- defaults.capabilities =
			-- 	vim.tbl_deep_extend("force", defaults.capabilities, require("blink.cmp").get_lsp_capabilities())
		end,
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- if you lazy load treesitter, you'll get an error when opening a lua file from the command line, even if you use
		-- the `VeryLazy` event, so do not lazy load.
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
		},
		keys = {
			{ "<leader>t.", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
		},
		init = function()
			vim.hl = vim.highlight -- treesitter workaround
		end,
		opts = {
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = { "dart", "htmldjango" },
			},
			auto_install = true,
			ensure_installed = vim.list_extend(
				config.options.treesitter.ensure_installed_base,
				config.options.treesitter.ensure_installed
			),
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					-- Disabling for dart because it was causing a few seconds of delay when creating
					-- a new line in the file.
					-- https://github.com/UserNobody14/tree-sitter-dart/issues/48
					-- https://github.com/UserNobody14/tree-sitter-dart/issues/46
					-- https://github.com/nvim-treesitter/nvim-treesitter/issues/4945
					disable = { "dart" },
					keymaps = {
						["ak"] = { query = "@block.outer", desc = "Around block" },
						["ik"] = { query = "@block.inner", desc = "Inside block" },
						["ac"] = { query = "@class.outer", desc = "Around class" },
						["ic"] = { query = "@class.inner", desc = "Inside class" },
						["a?"] = { query = "@conditional.outer", desc = "Around conditional" },
						["i?"] = { query = "@conditional.inner", desc = "Inside conditional" },
						["af"] = { query = "@function.outer", desc = "Around function" },
						["if"] = { query = "@function.inner", desc = "Inside function" },
						["al"] = { query = "@loop.outer", desc = "Around loop" },
						["il"] = { query = "@loop.inner", desc = "Inside loop" },
						["aa"] = { query = "@parameter.outer", desc = "Around argument" },
						["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
					},
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@block.outer"] = "V",
						["@conditional.outer"] = "V",
						["@loop.outer"] = "V",
						["@class.outer"] = "V", -- blockwise
					},
					include_surrounding_whitespace = false,
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = { query = "@class.outer", desc = "Next class start" },
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
				lsp_interop = {
					enable = true,
					border = "rounded",
					peek_definition_code = {
						["gF"] = "@function.outer",
						["gC"] = "@class.outer",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		lazy = true,
		opts = {
			opts = {
				enable_close = false,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		},
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
										if utils.table_contains(only_nonels_formatting_filetypes, ft) then
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

	-- python
	{ "jmcantrell/vim-virtualenv", ft = "python" },

	-- annotations
	{
		"danymat/neogen",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
		},
		opts = {
			snippet_engine = "luasnip",
		},
		keys = {
			{ "<localleader>g", "<cmd>lua require('neogen').generate()<cr>", desc = "Generate annotations" },
		},
	},

	-- snacks for lsp progress
	{
		"folke/snacks.nvim",
		event = "LspAttach",
		config = function(_, opts)
			local snacks = require("snacks")
			snacks.setup(opts)

			vim.api.nvim_set_hl(0, "LspProgressGrey", { fg = "#333333" })
			vim.api.nvim_set_hl(0, "LspProgressGreyBold", { fg = "#333333", bold = true })
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
						focusable = false,
						level = 0,
						style = function(buf, notif, ctx)
							notif.win.opts.focusable = false
							notif.win.opts.wo.winblend = 70
							local title = vim.trim(notif.icon .. " " .. (notif.title or ""))
							if title ~= "" then
								ctx.opts.title = { { " " .. title .. " ", ctx.hl.title } }
								ctx.opts.title_pos = "center"
							end
							vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
						end,
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
		end,
	},
}

return M
