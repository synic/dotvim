nnoremap <silent><buffer> gd <C-]>
nnoremap <silent><buffer> q <cmd>q<cr>
if has('nvim')
  lua vim.wo.list = false
end
