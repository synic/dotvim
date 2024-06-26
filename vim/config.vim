set colorcolumn=80
set signcolumn=yes
let s:last_search_term = ''
let s:current_equalalways = 1

" install vim-plug if it's not already installed
" commit hash is Feb, 2024, tag 0.13.0
if empty(glob('$VIMHOME/autoload/plug.vim'))
	silent !curl -sfLo $VIMHOME/autoload/plug.vim --create-dirs
	  \ https://raw.githubusercontent.com/junegunn/vim-plug/854b081934dd6114a03df712d9f5c3a5818c7c94/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | bdelete | colorscheme gruvbox-material
endif

let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
let g:EasyMotion_startofline = 1
let g:EasyMotion_do_mapping = 0

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#whitespace#enabled = 0

if !empty(glob('$VIMHOME/autoload/plug.vim'))
	call plug#begin('$VIMHOME/vim/plugins')

	Plug 'Lokaltog/vim-easymotion'
	Plug 'sainnhe/gruvbox-material'
	Plug 'bling/vim-airline'

	call plug#end()
endif

nnoremap <silent><leader>w/ <cmd>vsplit<cr>
nnoremap <silent><leader>w- <cmd>split<cr>
nnoremap <silent><leader>wh <cmd>wincmd h<cr>
nnoremap <silent><leader>wj <cmd>wincmd j<cr>
nnoremap <silent><leader>wk <cmd>wincmd k<cr>
nnoremap <silent><leader>wl <cmd>wincmd l<cr>
nnoremap <silent><leader>wd <cmd>q<cr>
nnoremap <silent><leader>wc <cmd>close<cr>
vnoremap <leader><leader> <plug>(easymotion-bd-f)
nnoremap <leader><leader> <plug>(easymotion-overwin-f)
nnoremap <silent><leader>tn <cmd>set number!<cr>
nnoremap <silent><leader>th <cmd>set nohlsearch!<cr>
nnoremap - <cmd>edit .<cr>

try
	colorscheme gruvbox-material
	let g:gruvbox_material_background = 'hard'
	hi ColorColumn guibg=#303030 ctermbg=236
catch /^Vim\%((\a\+)\)\=:E185/
	colorscheme desert
endtry

" netrw configuration
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide =
	    \ '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

autocmd VimResized * :wincmd =
autocmd BufEnter * silent! lcd %:p:h
