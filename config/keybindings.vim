" VIM Base and Plugin Keybindings
" Use `zR` to open all folds

" ### REMAP ESCAPE KEY {{{1
"----------------------------------------------------------------------------"
inoremap fd <esc>
vnoremap fd <esc>

" ### CONFIGURATION FILES {{{1
"----------------------------------------------------------------------------"
nmap <silent> <space>fed :e $VIMHOME/config/vimrc<cr>
nmap <silent> <space>fes :e $VIMHOME/config<cr>

" ### CUSTOM TEXT OBJECTS {{{1
"----------------------------------------------------------------------------"
map yig :call SelectBuffer()<cr>
map vig ggVG

" ### SEARCHING {{{1
"----------------------------------------------------------------------------"
map /  <plug>(incsearch-forward)
map ?  <plug>(incsearch-backward)
map g/ <plug>(incsearch-stay)

map n  <plug>(incsearch-nohl-n)
map N  <plug>(incsearch-nohl-N)
map *  <plug>(incsearch-nohl-*)
map #  <plug>(incsearch-nohl-#)
map g* <plug>(incsearch-nohl-g*)
map g# <plug>(incsearch-nohl-g#)

" ### GIT/REVISION CONTROL {{{1
"----------------------------------------------------------------------------"
nnoremap <silent> <space>gs :Gstatus<cr>
nnoremap <silent> <space>gd :Gdiff<cr>
nnoremap <silent> <space>gc :Gcommit<cr>
nnoremap <silent> <space>gb :Gblame<cr>
nnoremap <silent> <space>gl :Glog<cr>
nnoremap <silent> <space>gp :Git push<cr>
nnoremap <silent> <space>gr :Gread<cr>
nnoremap <silent> <space>gw :Gwrite<cr>
nnoremap <silent> <space>ge :Gedit<cr>
nnoremap <silent> <space>gi :Git add %<cr>
map <space>gr :Gist --private<cr>
map <space>gR :Gist --public<cr>
map <space>gs :call magit#show_magit('h')<cr>

" ### SYNTAX CHECKING {{{1
"----------------------------------------------------------------------------"
" go to next error
nnoremap <silent> <space>en :lnext<cr> 
" go to previous error
nnoremap <silent> <space>ep :lprev<cr>


" ### COMMENTING {{{1
"----------------------------------------------------------------------------"
nmap <space>cl :call ToggleComment()<cr>
vmap <space>cl :call ToggleComment()<cr>

" ### WINDOW MANAGEMENT {{{1
"----------------------------------------------------------------------------"
nmap <silent> <space>wk :wincmd k<cr>
nmap <silent> <space>wj :wincmd j<cr>
nmap <silent> <space>wh :wincmd h<cr>
nmap <silent> <space>wl :wincmd l<cr>
nmap <silent> <space><tab> :b#<cr>
nmap <silent> <space>w/ :call WindowCommand(':vs')<cr>
nmap <silent> <space>w- :call WindowCommand(':sp')<cr>
nmap <silent> <space>wc :call WindowCommand(':close')<cr>
nmap <silent> <space>wd :call WindowCommand(':q')<cr>
nmap <silent> <space>w= <C-w>=
nmap <silent> <space>wJ :call WindowCommand(':Qj')<cr>
nmap <silent> <space>wH :call WindowCommand(':Qh')<cr>
nmap <silent> <space>wK :call WindowCommand(':Qk')<cr>
nmap <silent> <space>wL :call WindowCommand(':Ql')<cr>
nmap <silent> <space>wm :ZoomToggle<cr>
nmap <silent> <space>wM :tabedit %<cr>
nmap <silent> <space>w1 :execute ':1wincmd w'<cr>
nmap <silent> <space>w2 :execute ':2wincmd w'<cr>
nmap <silent> <space>w3 :execute ':3wincmd w'<cr>
nmap <silent> <space>w4 :execute ':4wincmd w'<cr>
nmap <silent> <space>w5 :execute ':5wincmd w'<cr>
nmap <silent> <space>w6 :execute ':6wincmd w'<cr>
nmap <silent> <space>w7 :execute ':7wincmd w'<cr>
nmap <silent> <space>w8 :execute ':8wincmd w'<cr>
nmap <silent> <space>w9 :execute ':9wincmd w'<cr>
nmap <silent> <space>wC1 :execute ':1wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC2 :execute ':2wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC3 :execute ':3wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC4 :execute ':4wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC5 :execute ':5wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC6 :execute ':6wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC7 :execute ':7wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC8 :execute ':8wincmd w'<cr>:call WindowCommand(':close')<cr>
nmap <silent> <space>wC9 :execute ':9wincmd w'<cr>:call WindowCommand(':close')<cr>

" ### BUFFERS {{{1
"----------------------------------------------------------------------------"
nnoremap <silent> <space>bb :CtrlPBuffer<cr>

" ### TABS/LAYOUT {{{1
"----------------------------------------------------------------------------"
nnoremap <silent> <space>ll :$tabnew<cr>:Startify<cr>
nnoremap <silent> <space>ln :tabnext<cr>
nnoremap <silent> <space>lp :tabprev<cr>
nnoremap <silent> <space>lc :tabclose<cr>
nnoremap <silent> <space>l1 1gt
nnoremap <silent> <space>l2 2gt
nnoremap <silent> <space>l3 3gt
nnoremap <silent> <space>l4 4gt
nnoremap <silent> <space>l5 5gt
nnoremap <silent> <space>l6 6gt
nnoremap <silent> <space>l7 7gt
nnoremap <silent> <space>l8 8gt
nnoremap <silent> <space>l9 9gt

" ### MOVEMENT {{{1
"----------------------------------------------------------------------------"
map <space><space> <plug>(easymotion-bd-f)
nmap <space><space> <plug>(easymotion-overwin-f)

" ### HOMEPAGE {{{1
"----------------------------------------------------------------------------"
nmap <space>bh :Startify<cr>

" ### FILE MANAGEMENT {{{1
"----------------------------------------------------------------------------"
map - :call NetRWCurrentFile()<cr>
nmap <silent> <space>fn :call NERDTreeCurrentFile()<cr>

" ### SESSIONS {{{1
"----------------------------------------------------------------------------"
map <space>ls :call SessionSavePrompt()<cr>
map <space>ld :call SessionDeletePrompt()<cr>

" ### TOGGLES {{{1
"----------------------------------------------------------------------------"
" toggle relative line numbering
nmap <silent> <space>tr :call NumberToggle()<cr>
" toggle line numbering
nmap <silent> <space>tn :set number!<cr>

" toggle search highlighting
nmap <silent> <space>th :set nohlsearch!<cr>
" remove last search 
nmap <silent> ,, :noh<cr>

" golden ratio
map <space>tg :call ToggleGoldenRatio()<cr>

" ### PROJECT MANAGEMENT {{{1
"----------------------------------------------------------------------------"
map _ :call NetRWCurrentProject()<cr>
nmap <silent> <space>ph :CtrlP<cr>
nmap <silent> <space>pf :CtrlP<cr>
nmap <silent> <space>pn :call NERDTreeCurrentProject()<cr>
nmap <silent> <space>pd :NERDTreeClose<cr>

" project searching
nmap <silent> <space>* :CtrlSF<cr>
nmap <silent> <space>sp :call SearchInProjectRoot()<cr>

" gundo
nmap <silent> <space>ag :GundoToggle<cr>

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost keybindingsvim source %

" vim:foldmethod=marker
