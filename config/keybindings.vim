" VIM Base and Plugin Keybindings
" Use `zR` to open all folds

" ### WINDOW MANAGEMENT {{{1
"----------------------------------------------------------------------------"
nnoremap <silent><leader>wm <cmd>ZoomToggle<cr>
nnoremap <silent><leader>wM <cmd>tabedit %<cr>
nnoremap <silent><leader>w/ <cmd>vsplit<cr>
nnoremap <silent><leader>w- <cmd>split<cr>
nnoremap <silent><leader>wh <cmd>wincmd h<cr>
nnoremap <silent><leader>wj <cmd>wincmd j<cr>
nnoremap <silent><leader>wk <cmd>wincmd k<cr>
nnoremap <silent><leader>wl <cmd>wincmd l<cr>

" ### MOVEMENT {{{1
"----------------------------------------------------------------------------"
vnoremap <leader><leader> <plug>(easymotion-bd-f)
nnoremap <leader><leader> <plug>(easymotion-overwin-f)

" ### TOGGLES {{{1
"----------------------------------------------------------------------------"
" toggle relative line numbering
nnoremap <silent><leader>tr <cmd>call NumberToggle()<cr>
" toggle line numbering
nnoremap <silent><leader>tn <cmd>set number!<cr>

" toggle search highlighting
nnoremap <silent><leader>th <cmd>set nohlsearch!<cr>
" remove last search
nnoremap <silent> ,, <cmd>noh<cr>

" ### PROJECT MANAGEMENT {{{1
"----------------------------------------------------------------------------"
nnoremap - <cmd>edit .<cr>
nnoremap _ <cmd>call NetRWCurrentProject()<cr>

" ### COMMAND MODIFICATIONS {{{1
"spaces-spaces-spaces-spaces-------------------------------------------------------------------------"
" make J join lines without inserting spaces
nnoremap J <cmd>call JoinSpaceless()<CR>

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost keybindings.vim source %

" vim:foldmethod=marker
