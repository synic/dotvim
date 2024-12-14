setlocal foldmethod=marker
setlocal ts=2
setlocal sts=2
setlocal sw=2

" dadbod
lua <<EOF
		vim.keymap.set('n', '<localleader>W', '<Plug>(DBUI_SaveQuery)', { buffer = true, desc = "Save query" })
		vim.keymap.set('n', '<localleader>E', '<Plug>(DBUI_EditBindParameters)', { buffer = true, desc = "Edit bind parameters" })
		vim.keymap.set('n', '<localleader>S', '<Plug>(DBUI_ExecuteQuery)', { buffer = true, desc = "Execute query" })
		vim.keymap.set('v', '<localleader>S', '<Plug>(DBUI_ExecuteQuery)', { buffer = true, desc = "Execute query" })
EOF
