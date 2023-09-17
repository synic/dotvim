nnoremap <silent><buffer> gd <C-]>
nnoremap <silent><buffer> q :q<cr>
if has('nvim')
  lua vim.wo.list = false
end
