" Autocommands
" Use `zR` to open all folds
"
" ### Equalize Windows After Plugins Close {{{1
"----------------------------------------------------------------------------"

autocmd! FileType fugitiveblame nnoremap <buffer> q :q<CR>wincmd =
autocmd! FileType ctrlsf nnoremap <buffer> q :q<CR>wincmd =

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost autocmds.vim source %

" vim:foldmethod=marker
