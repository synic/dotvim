" map the escape key to `fd`
imap fd <Esc>
vmap fd <Esc>

" Misc
map yig :call SelectBuffer()<cr>
map vig ggVG

" Change the leader key to spacebar
let mapleader = '\<space>'

" set up hlsearch toggling with F4 as the hotkey
noremap <F4> :set hlsearch! hlsearch?<cr>

" fugitive
nnoremap <silent> <leader>gs :Gstatus<cr>
nnoremap <silent> <leader>gd :Gdiff<cr>
nnoremap <silent> <leader>gc :Gcommit<cr>
nnoremap <silent> <leader>gb :Gblame<cr>
nnoremap <silent> <leader>gl :Glog<cr>
nnoremap <silent> <leader>gp :Git push<cr>
nnoremap <silent> <leader>gr :Gread<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>ge :Gedit<cr>
nnoremap <silent> <leader>gi :Git add %<cr>
nnoremap <silent> <leader>gg :SignifyToggle<cr>

" location list
nnoremap <silent> <space>en :lnext<cr>

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
nmap <silent> <space>fed :e ~/.vimrc<cr>
nmap <silent> <space>w1 :execute ':1wincmd w'<cr>
nmap <silent> <space>w2 :execute ':2wincmd w'<cr>
nmap <silent> <space>w3 :execute ':3wincmd w'<cr>
nmap <silent> <space>w4 :execute ':4wincmd w'<cr>
nmap <silent> <space>w5 :execute ':5wincmd w'<cr>
nmap <silent> <space>w6 :execute ':6wincmd w'<cr>
nmap <silent> <space>w7 :execute ':7wincmd w'<cr>
nmap <silent> <space>w8 :execute ':8wincmd w'<cr>
nmap <silent> <space>w9 :execute ':9wincmd w'<cr>

" syntastic
nnoremap <space>ss :SyntasticCheck<cr>

" git
map <space>gr :Gist<cr>
map <space>gs :call magit#show_magit('h')<cr>
nmap <space>gb :Gblame<cr>
nmap <space>ga :Gadd<cr>
nmap <space>gl :Glog<cr>

" easymotion
map <space><space> <plug>(easymotion-bd-f)
nmap <space><space> <plug>(easymotion-overwin-f)

" startify
nmap <space>bh :Startify<cr>

" Searching, etc
nmap <space>sp :call GrepProject()<cr>
nmap <space>sd :call GrepProjectCurrentDir()<cr>
nmap <space>sr :call SearchAndReplaceInProject()<cr>

" file management
map - :call NetRWCurrentFile()<cr>
map _ :call NetRWCurrentProject()<cr>

" golden ratio
map <space>tg :call ToggleGoldenRatio()<cr>

" sessions
map <space>ls :call SessionSavePrompt()<cr>
map <space>ld :call SessionDeletePrompt()<cr>

" join lines while removing extra spaces
nnoremap J :call JoinSpaceless()<cr>

" toggle relative line numbering
nmap <space>tr :call NumberToggle()<cr>

