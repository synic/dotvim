" Autocommands
" Use `zR` to open all folds
"

" ### WINDOW RESIZING {{{1
"----------------------------------------------------------------------------"
autocmd VimResized * :wincmd =

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"

" automatically change to the file's directory when editing
autocmd BufEnter * lcd %:p:h

" auto-reload this file when saving
autocmd! bufwritepost autocmds.vim source %

" vim:foldmethod=marker
