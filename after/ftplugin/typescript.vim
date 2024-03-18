setlocal expandtab
setlocal softtabstop=2
setlocal tabstop=2
setlocal shiftwidth=2
setlocal textwidth=0
setlocal cindent
setlocal autoindent
setlocal smartindent

if has('nvim')
  lua << END_OF_LUA
    vim.api.nvim_buf_set_keymap(
      0,
      'n',
      'gO',
      '<cmd>lua vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments={vim.fn.expand("%:p") }})<cr>',
      { desc = 'Organize imports' }
    )

    vim.api.nvim_buf_set_keymap(
      0,
      'n',
      '<localleader>f',
      '<cmd>TypescriptRenameFile<cr>',
      { desc = 'Rename file' }
    )
END_OF_LUA
end
