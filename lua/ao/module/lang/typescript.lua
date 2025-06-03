local keymap = require("ao.keymap")

return {
	treesitter = { "typescript", "javascript" },
	only_nonels_formatting = true,
	nonels = {
		["formatting.prettierd"] = {
			filetypes = { "typescript", "javascript", "templ" },
		},
		["formatting.prettier"] = {
			filetypes = { "svelte" },
		},
	},
	plugins = {
		{
			"pmizio/typescript-tools.nvim",
			ft = { "typescript", "javascript", "html", "templ" },
			dependencies = { "nvim-lua/plenary.nvim" },
			config = true,
		},
	},
	servers = {
		["ts_ls"] = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
			root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		},
	},
	on_attach = function(client)
		-- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
		-- `vim.lsp.buf.code_action()` if specified in `context.only`.
		vim.api.nvim_buf_create_user_command(0, "LspTypescriptSourceAction", function()
			local source_actions = vim.tbl_filter(function(action)
				return vim.startswith(action, "source.")
			end, client.server_capabilities.codeActionProvider.codeActionKinds)

			vim.lsp.buf.code_action({
				---@diagnostic disable-next-line: missing-fields
				context = {
					only = source_actions,
				},
			})
		end, {})
		vim.lsp.handlers["_typescript.rename"] = function(_, result, _)
			vim.lsp.util.show_document({
				uri = result.textDocument.uri,
				range = {
					start = result.position,
					["end"] = result.position,
				},
			}, client.offset_encoding)
			vim.lsp.buf.rename()
			return vim.NIL
		end

		keymap.add({
			{ "<localleader>o", "<cmd>TSToolsOrganizeImports", desc = "Organize imports" },
			{ "<localleader>f", "<cmd>TSToolsRenameFile<cr>", desc = "Rename file" },
		})
	end,
}
