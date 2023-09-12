" VIM Plugin Specific Settings
" Use `zR` to open all folds

" ### Lokaltog/vim-easymotion {{{1
"----------------------------------------------------------------------------"
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
let g:EasyMotion_startofline = 1 " don't keep cursor column when JK motion
let g:EasyMotion_do_mapping = 0

" ### bling/vim-airline {{{1
"----------------------------------------------------------------------------"
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#whitespace#enabled = 0

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost pluginsettings.vim source %

" vim:foldmethod=marker
