local config = require("ao.config")
local keymap = require("ao.keymap")

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})
local md_namespace = vim.api.nvim_create_namespace("LspFloat")

local M = {}

M.enhanced_float_handler = function(handler)
	return function(err, result, ctx, conf)
		local buf, win = handler(
			err,
			result,
			ctx,
			vim.tbl_deep_extend("force", conf or {}, {
				border = "rounded",
				max_width = math.floor(vim.o.columns * (vim.o.columns > 300 and 0.5 or 0.8)),
			})
		)

		if not buf or not win then
			return
		end

		vim.wo[win].concealcursor = "n"
		vim.wo[win].wrap = true
		vim.wo[win].linebreak = true

		for l, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
			for pattern, hl_group in pairs({
				["|%S-|"] = "@text.reference",
				["@%S+"] = "@parameter",
				["^%s*(Parameters:)"] = "@text.title",
				["^%s*(Return:)"] = "@text.title",
				["^%s*(See also:)"] = "@text.title",
				["{%S-}"] = "@parameter",
			}) do
				local from = 1 ---@type integer?
				while from do
					local to
					from, to = line:find(pattern, from)
					if from then
						vim.api.nvim_buf_set_extmark(buf, md_namespace, l - 1, from - 1, {
							end_col = to,
							hl_group = hl_group,
						})
					end
					from = to and to + 1 or nil
				end
			end
		end

		if not vim.b[buf].markdown_keys then
			vim.keymap.set("n", "K", function()
				local url = (vim.fn.expand("<cword>") --[[@as string]]):match("|(%S-)|")
				if url then
					return vim.cmd.help(url)
				end

				local col = vim.api.nvim_win_get_cursor(0)[2] + 1
				local from, to
				from, to, url = vim.api.nvim_get_current_line():find("%[.-%]%((%S-)%)")
				if from and col >= from and col <= to then
					vim.system({ "open", url }, nil, function(res)
						if res.code ~= 0 then
							vim.notify("Failed to open URL" .. url, vim.log.levels.ERROR)
						end
					end)
				end
			end, { buffer = buf, silent = true })
			vim.b[buf].markdown_keys = true
		end
	end
end

local function find_lang_def(lang_defs, ft)
	for _, def in ipairs(lang_defs) do
		if vim.tbl_contains(def.treesitter or {}, ft) or def._lang == ft then
			return def
		end
	end
end

local function setup_on_attach_event(lang_defs)
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local picker = require("snacks").picker
			local buf = ev.buf
			local ft = vim.bo[buf].filetype

			if ft == "oil" then
				return
			end

			keymap.add({
				{
					"<localleader>=",
					vim.lsp.buf.format,
					desc = "Format document",
					buffer = buf,
					mode = { "n", "v" },
				},
				{ "=", vim.lsp.buf.format, desc = "Format selection", buffer = buf, mode = { "v" } },

				{ "gd", picker.lsp_definitions, desc = "Definition(s)", buffer = buf },
				{ "gD", vim.lsp.buf.declaration, desc = "Declaration(s)", buffer = buf },
				{ "grs", picker.lsp_symbols, desc = "Document symbols", buffer = buf },
				{ "grw", picker.lsp_workspace_symbols, desc = "Workspace symbols", buffer = buf },
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
				{ "K", vim.lsp.buf.hover, desc = "Hover", buffer = buf },
			})

			local def = find_lang_def(lang_defs, ft)

			if def then
				local lang_on_attach = def.on_attach
				if type(lang_on_attach) == "function" then
					local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
					lang_on_attach(client)
				end

				local format_on_save = def.format_on_save
				if format_on_save == nil then
					format_on_save = true
				end

				if format_on_save then
					vim.api.nvim_clear_autocmds({ group = lsp_formatting_group, buffer = buf })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = lsp_formatting_group,
						buffer = buf,
						callback = function()
							local format_opts = { bufnr = buf, timeout = 4000 }
							if format_on_save == "nonels" then
								format_opts.filter = function(c)
									return c.name == "null-ls"
								end
							end
							vim.lsp.buf.format(format_opts)
						end,
					})
				end
			end
		end,
	})
end

local function unique(...)
	return vim.fn.uniq(vim.fn.sort(vim.iter({ ... }):flatten():totable()))
end

M.default_lsp_config = {
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			},
		},
	},
	root_markers = { ".git" },
}

vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ", -- Nerd Font error icon
			[vim.diagnostic.severity.WARN] = " ", -- Nerd Font warning icon
			[vim.diagnostic.severity.INFO] = " ", -- Nerd Font info icon
			[vim.diagnostic.severity.HINT] = " ", -- Nerd Font hint icon
		},
	},
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.lsp.config("*", M.default_lsp_config)

---@type LazySpec[]
local plugins = {}
local lang_defs = {}
local to_import = unique(config.options.languages, config.options.extra_languages)

---@diagnostic disable-next-line: param-type-mismatch
for _, lang in ipairs(to_import) do
	if vim.fn.filereadable(vim.fn.stdpath("config") .. "/ao/module/lang/" .. lang .. ".lua") then
		local ok, m = pcall(require, "ao.module.lang." .. lang)

		if not ok then
			table.insert(lang_defs, {})
		else
			table.insert(lang_defs, m)

			m._lang = lang
			if m.plugins then
				plugins = vim.iter({ plugins, m.plugins }):flatten():totable()
			end
		end
	end
end

function M.get_treesitter_plugins(defs)
	return {
		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "main",
			build = ":TSUpdate",
			-- if you lazy load treesitter, you'll get an error when opening a lua file from the command line, even if you use
			-- the `VeryLazy` event, so do not lazy load.
			lazy = false,
			dependencies = {
				{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
				{
					"nvim-treesitter/nvim-treesitter-context",
					opts = { max_lines = 7 },
				},
				"windwp/nvim-ts-autotag",
			},
			keys = {
				{ "<leader>t.", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
			},
			init = function()
				vim.api.nvim_create_autocmd("FileType", {
					pattern = "*",
					callback = function()
						pcall(vim.treesitter.start)
					end,
				})

				vim.hl = vim.highlight -- treesitter workaround
			end,
			config = function(_, opts)
				require("nvim-treesitter").setup(opts)
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
				ensure_installed = vim.iter(defs)
					:map(function(def)
						return def.treesitter or {}
					end)
					:flatten()
					:totable(),
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
		},
	}
end

function M.get_lsp_plugins(defs)
	local langs = {}
	local nonels = {}
	local mason_servers = {}

	for _, def in ipairs(defs) do
		if def.treesitter then
			langs = vim.iter({ langs, def.treesitter }):flatten():totable()
		else
			langs = vim.iter({ langs, { def._lang } }):flatten():totable()
		end

		if type(def.servers) == "table" then
			for server, conf in pairs(def.servers) do
				local use_mason = true

				if conf.use_mason ~= nil then
					use_mason = conf.use_mason
					conf.use_mason = nil
				end

				if use_mason then
					mason_servers[#mason_servers + 1] = server
				end

				vim.lsp.config[server] = conf
				vim.lsp.enable(server)
			end
		end

		if def.nonels then
			for k, v in pairs(def.nonels) do
				if type(k) == "number" then
					table.insert(nonels, v)
				else
					nonels[k] = v
				end
			end
		end
	end

	setup_on_attach_event(defs)

	return {
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
				local sources = {}

				for source, args in pairs(nonels) do
					if type(source) == "number" then
						table.insert(sources, require("null-ls.builtins." .. args))
					else
						table.insert(sources, require("null-ls.builtins." .. source).with(args))
					end
				end

				return { sources = sources }
			end,
		},

		{
			"mason-org/mason-lspconfig.nvim",
			opts = {
				automatic_enable = mason_servers,
				ensure_installed = mason_servers,
			},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
			},
		},

		-- to show lsp progress
		{
			"j-hui/fidget.nvim",
			event = "LspAttach",
			opts = {
				notification = { window = { winblend = 20 } },
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

M.plugins = vim.iter({
	plugins,
	{
		{ "mason-org/mason.nvim", opts = {}, lazy = false },
	},
	M.get_treesitter_plugins(lang_defs),
	M.get_lsp_plugins(lang_defs),
})
	:flatten()
	:totable()

return M
