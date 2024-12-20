local utils = require("ao.utils")

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})
local flags = { allow_incremental_sync = true, debounce_text_changes = 200 }

local function lsp_on_attach(_, bufnr)
	local telescope = require("telescope.builtin")
	local ft = vim.bo[bufnr].filetype

	utils.map_keys({
		{ "<localleader>r", vim.lsp.buf.rename, desc = "Rename symbol", buffer = bufnr },
		{ "<localleader>,", vim.lsp.buf.code_action, desc = "Code actions", buffer = bufnr },
		{ "<localleader>=", vim.lsp.buf.format, desc = "Format document", buffer = bufnr, modes = { "n", "v" } },
		{ "<localleader>^", "<cmd>LspRestart<cr>", desc = "Restart LSP", buffer = bufnr },
		{ "<localleader>$", "<cmd>LspInfo<cr>", desc = "LSP Info", buffer = bufnr },
		{ "=", vim.lsp.buf.format, desc = "Format selection", buffer = bufnr, modes = { "v" } },

		{ "gd", telescope.lsp_definitions, desc = "Definition(s)", buffer = bufnr },
		{ "gD", vim.lsp.buf.declaration, desc = "Declaration(s)", buffer = bufnr },
		{ "g/", "<cmd>vsplit<cr><cmd>Telescope lsp_definitions<cr>", desc = "Goto def in vsplit", buffer = bufnr },
		{ "g-", "<cmd>split<cr><cmd>Telescope lsp_definitions<cr>", desc = "Goto def in hsplit", buffer = bufnr },
		{ "gr", telescope.lsp_references, desc = "Reference(s)", buffer = bufnr },
		{ "gI", telescope.lsp_implementations, desc = "Implementation(s)", buffer = bufnr },
		{ "g.", telescope.lsp_document_symbols, desc = "Document symbols", buffer = bufnr },
		{ "gW", telescope.lsp_dynamic_workspace_symbols, desc = "Workspace symbols", buffer = bufnr },
		{ "K", vim.lsp.buf.hover, desc = "Hover", buffer = bufnr },
	})

	if ft == "typescript" then
		utils.map_keys({
			{ "<localleader>o", "<cmd>TSToolsOrganizeImports", desc = "Organize imports" },
			{ "<localleader>f", "<cmd>TSToolsRenameFile<cr>", desc = "Rename file" },
		})
	end
end

return {
	-- configure mason packages with LSP
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
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"lua_ls",
				"gopls",
				"ruff",
				"pyright",
				"vimls",
				"bashls",
				"emmet_language_server",
			},
			automatic_installation = true,
		},
		init = function()
			vim.filetype.add({ extension = { templ = "templ" } })
		end,
		config = function(_, opts)
			local lsp = require("lspconfig")
			local m = require("mason-lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			opts.handlers = {
				["lua_ls"] = function()
					lsp.lua_ls.setup({
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						flags = flags,
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
					lsp.htmx.setup({
						flags = flags,
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						filetypes = { "html", "templ", "htmldjango" },
					})
				end,

				["tailwindcss"] = function()
					lsp.tailwindcss.setup({
						flags = flags,
						on_attach = lsp_on_attach,
						capabilities = capabilities,
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
					lsp.rust_analyzer.setup({
						flags = flags,
						capabilities = capabilities,
						on_attach = lsp_on_attach,
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
					lsp.templ.setup({
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						flags = flags,
						filetypes = { "templ" },
					})
				end,

				["ts_ls"] = function()
					lsp.ts_ls.setup({
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						flags = flags,
						filetypes = { "templ", "javascript", "typescript", "html" },
					})
				end,

				["gopls"] = function()
					lsp.gopls.setup({
						flags = flags,
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						settings = {
							gopls = {
								buildFlags = { "-tags=debug,release,mage,tools" },
								completeUnimported = true,
								analyses = {
									unusedparams = true,
									fieldalignment = true,
								},
							},
						},
					})
				end,

				["pyright"] = function()
					lsp.pyright.setup({
						flags = flags,
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						settings = {
							python = {
								-- analysis = {
								-- 	typeCheckingMode = "off",
								-- },
							},
						},
					})
				end,

				["basedpyright"] = function()
					lsp.basedpyright.setup({
						flags = flags,
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						settings = {
							python = {
								typeCheckingMode = "off",
							},
						},
					})
				end,

				["emmet_language_server"] = function()
					local c = vim.lsp.protocol.make_client_capabilities()
					c.textDocument.completion.completionItem.snippetSupport = true
					lsp.emmet_language_server.setup({
						-- on_attach = on_attach,
						capabilities = capabilities,
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
					server_name = server_name == "tsserver" and "ts_ls" or server_name
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						on_attach = lsp_on_attach,
						flags = flags,
					})
				end,
			}

			m.setup(opts)
		end,
	},

	-- neovim development
	{
		"folke/lazydev.nvim",
		dependencies = { "Bilal2453/luvit-meta" },
		ft = "lua",
		opts = {
			library = {
				"luvit-meta/library",
			},
		},
	},

	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			on_attach = lsp_on_attach,
		},
	},

	-- lsp
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/nvim-cmp", "williamboman/mason-lspconfig.nvim" },
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
			servers = {
				dartls = {
					setup = {
						on_attach = lsp_on_attach,
						flags = flags,
						cmd = { "dart", "language-server", "--protocol=lsp" },
					},
				},
			},
		},
		config = function(_, opts)
			local lsp = require("lspconfig")
			local defaults = lsp.util.default_config

			vim.diagnostic.config(opts.diagnostic)
			lsp.dartls.setup(opts.servers.dartls.setup)

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
			{ "windwp/nvim-ts-autotag" },
		},
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
			ensure_installed = {
				"lua",
				"vimdoc",
			},
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
			local ns = require("null-ls")

			-- only use none-ls for formatting these filetypes; the rest can use any formatter
			local only_nonels_formatting_filetypes = {
				"lua",
				"typescript",
				"javascript",
				"go",
				"svelte",
				-- "elixir",
			}

			return {
				sources = {
					-- formatting
					ns.builtins.formatting.stylua,
					ns.builtins.formatting.shfmt,
					ns.builtins.formatting.djhtml.with({
						"--tabwidth=2",
					}),
					-- ns.builtins.formatting.mix,
					-- ns.builtins.formatting.surface,
					ns.builtins.formatting.prettierd.with({
						filetypes = { "typescript", "javascript", "templ" },
					}),
					ns.builtins.formatting.prettier.with({
						filetypes = { "svelte" },
					}),
					ns.builtins.formatting.gofmt,
					ns.builtins.formatting.goimports_reviser,
					ns.builtins.formatting.golines,
					ns.builtins.formatting.isort,
					ns.builtins.formatting.black,
					ns.builtins.formatting.pg_format.with({
						extra_args = { "-s", "2", "-u", "1", "-w", "120" },
					}),
					ns.builtins.formatting.dart_format,
					-- ns.builtins.formatting.rustywind.with({
					-- 	filetypes = { "typescript", "javascript", "css", "templ", "html", "htmldjango", "elixir" },
					-- }),

					require("none-ls.formatting.trim_whitespace"),

					-- diagnostics
					ns.builtins.diagnostics.gitlint,
					-- ns.builtins.diagnostics.mypy,
					ns.builtins.diagnostics.trail_space.with({
						disabled_filetypes = { "ctrlsf" },
					}),
					ns.builtins.diagnostics.yamllint,
					ns.builtins.diagnostics.hadolint, -- Dockerfile
					ns.builtins.diagnostics.markdownlint_cli2,
					ns.builtins.diagnostics.buf, -- protobuf
					ns.builtins.diagnostics.codespell,

					-- completion
					ns.builtins.completion.spell,
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
}
