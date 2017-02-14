" map the escape key to `fd`
imap fd <Esc>
vmap fd <Esc>

" misc
map yig :call SelectBuffer()<cr>
map vig ggVG

" search
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" fugitive
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

" location list
nnoremap <silent> <space>en :lnext<cr>
nnoremap <silent> <space>ep :lprev<cr>

" commenting
nmap <space>cl :call ToggleComment()<cr>
vmap <space>cl :call ToggleComment()<cr>

" easy window switching
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
nmap <silent> <space>fed :e ~/.vim/vimrc<cr>
nmap <silent> <space>w1 :execute ':1wincmd w'<cr>
nmap <silent> <space>w2 :execute ':2wincmd w'<cr>
nmap <silent> <space>w3 :execute ':3wincmd w'<cr>
nmap <silent> <space>w4 :execute ':4wincmd w'<cr>
nmap <silent> <space>w5 :execute ':5wincmd w'<cr>
nmap <silent> <space>w6 :execute ':6wincmd w'<cr>
nmap <silent> <space>w7 :execute ':7wincmd w'<cr>
nmap <silent> <space>w8 :execute ':8wincmd w'<cr>
nmap <silent> <space>w9 :execute ':9wincmd w'<cr>

" buffers
nnoremap <silent> <space>bb :CtrlPBuffer<cr>

" tabs
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

" git
map <space>gr :Gist --private<cr>
map <space>gR :Gist --public<cr>
map <space>gs :call magit#show_magit('h')<cr>

" easymotion
map <space><space> <plug>(easymotion-bd-f)
nmap <space><space> <plug>(easymotion-overwin-f)

" startify
nmap <space>bh :Startify<cr>

" file management
map - :call NetRWCurrentFile()<cr>
map _ :call NetRWCurrentProject()<cr>

" golden ratio
map <space>tg :call ToggleGoldenRatio()<cr>

" sessions
map <space>ls :call SessionSavePrompt()<cr>
map <space>ld :call SessionDeletePrompt()<cr>

" toggle relative line numbering
nmap <silent> <space>tr :call NumberToggle()<cr>

" toggle nerdtree
nmap <silent> <space>pn :call NERDTreeCurrentProject()<cr>
nmap <silent> <space>pc :call NERDTreeCurrentFile()<cr>
nmap <silent> <space>pd :NERDTreeClose<cr>

" project searching
nmap <silent> <space>* :CtrlSF<cr>
nmap <silent> <space>sp :call SearchInProjectRoot()<cr>

" gundo
nmap <silent> <space>ag :GundoToggle<cr>

" toggles
nmap <silent> <space>th :set nohlsearch!<cr>
nmap <silent> ,, :noh<cr>

" auto-reload this file when saving
autocmd! bufwritepost keybindings.vim source %
