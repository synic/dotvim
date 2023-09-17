setlocal ts=2
setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal textwidth=115

if has('nvim')
  lua << END_OF_LUA
    vim.api.nvim_buf_set_keymap(
      0,
      'n',
      '<localleader>O',
      --'<cmd>lua vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments={vim.fn.expand("%:p") }})<cr>',
      '<cmd>TSToolsOrganizeImports<cr>',
      { desc = 'organize imports' }
    )

    vim.api.nvim_buf_set_keymap(
      0,
      'n',
      '<localleader>f',
      '<cmd>TypescriptRenameFile<cr>',
      { desc = 'rename file' }
    )
END_OF_LUA
end
