" ## Keybindings
"
" These are keybindings that don't need any plugins to work. Plugin specific
" keybindings can be found in `config/keybindings.vim` for regular vim and in
" each individual module (along with it's plugin config) in `lua/modules` for
" neovim.
"
" remap escape key
inoremap fd <esc>
vnoremap fd <esc>

" keep selection after indent
vnoremap < <gv
vnoremap > >gv

" select entire buffer
map vig ggVG

" window management
nmap <silent> <space>wk :wincmd k<cr>
nmap <silent> <space>wj :wincmd j<cr>
nmap <silent> <space>wh :wincmd h<cr>
nmap <silent> <space>wl :wincmd l<cr>
nmap <silent> <space><tab> :b#<cr>
nmap <silent> <space>w/ :vs<cr>
nmap <silent> <space>w- :sp<cr>
nmap <silent> <space>wc :close<cr>
nmap <silent> <space>wd :q<cr>
nmap <silent> <space>bd :q<cr>
nmap <silent> <space>w= <C-w>=
nmap <silent> <space>wJ :Qj<cr>
nmap <silent> <space>wH :Qh<cr>
nmap <silent> <space>wK :Qk<cr>
nmap <silent> <space>wL :Ql<cr>

" configuration management
nmap <silent> <space>fed :e $VIMHOME/<cr>

" toggle hlsearch
nnoremap <silent><space>ts :let &hls = !&hls<cr>

" line number toggles
nnoremap <silent> <space>tr :let &rnu = !&rnu<cr>
nnoremap <silent> <space>tn :let &nu = !&nu<cr>

" change to current file's director
nnoremap <silent> <space>cd :cd %:p:h<cr>

" open netrw at current file's directory
map - :execute 'edit ' . expand('%:p%:h')<cr>
nmap <silent> <space>ob 1<C-g>:<C-U>echo v:statusmsg<CR>

" layouts/tabs
nnoremap <silent> <space>ll :tabnew<cr>
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
