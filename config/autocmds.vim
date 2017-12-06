" Autocommands
" Use `zR` to open all folds
"

" ### WINDOW RESIZING {{{1
"----------------------------------------------------------------------------"
autocmd VimResized * :wincmd =

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost autocmds.vim source %

" vim:foldmethod=marker
