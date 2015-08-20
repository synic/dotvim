" Note: skip init for vim-tiny or vim-small
if 0 | endif

if has('vim_starting')
    if &compatible
        set nocompatible " disable vi settings
    endif

    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" set the correct python path for homebrew if we're on OS X
if has("unix")
  let s:uname = system("echo -n \"$(uname)\"")
  if s:uname == "Darwin"
    python import sys
    python sys.path.insert(0, '/usr/local/lib/python2.7/site-packages')
  endif
endif

" plugin list
call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

" python specific plugins
NeoBundle 'hynek/vim-python-pep8-indent'    " for auto indenting pep8 style
NeoBundle 'python-rope/ropevim'             " refactoring, finding occurrences
NeoBundle 'michaeljsmith/vim-indent-object' " for selecting indent objects
NeoBundle 'davidhalter/jedi-vim'            " for code completion

" misc plugins
NeoBundle 'rking/ag.vim'                    " project searching
NeoBundle 'embear/vim-localvimrc'           " per-project .vimrc
NeoBundle 'mattn/webapi-vim'
NeoBundle 'vim-scripts/openssl.vim'
NeoBundle 'tpope/vim-unimpaired'

" project management
NeoBundle 'jlanzarotta/bufexplorer'        " small buffer explorer
NeoBundle 'scrooloose/nerdtree'            " directory tree, project management
NeoBundle 'kien/ctrlp.vim'                 " fuzzy file searching
NeoBundle 'godlygeek/tabular'              " align text, even tables

" coding
NeoBundle 'pangloss/vim-javascript'        " javascript utils
NeoBundle 'vim-scripts/taglist.vim'        " shows classes, methods, etc
NeoBundle 'SirVer/ultisnips'               " textmate style snippets
NeoBundle 'honza/vim-snippets'             " the actual snippest themselves
NeoBundle 'tpope/vim-surround'             " add, change, delete surround text
NeoBundle 'scrooloose/syntastic'           " syntax checking
NeoBundle 'jmcantrell/vim-virtualenv'      " virtualenv
NeoBundle 'ntpeters/vim-better-whitespace' " highlights and removes spurious
                                           "    whitespace
NeoBundle 'tomtom/tcomment_vim'            " comment blocks of code

" syntax files
NeoBundle 'plasticboy/vim-markdown'        " markdown syntax highlighting
NeoBundle 'sudar/vim-arduino-syntax'       " arduino syntax file
NeoBundle 'gorodinskiy/vim-coloresque'     " highlight color codes in CSS
NeoBundle 'derekwyatt/vim-scala'           " scala syntax

" undo
NeoBundle 'sjl/gundo.vim'                  " undo tree

" git
NeoBundle 'mattn/gist-vim'                 " post gists to gist.github.com
NeoBundle 'tpope/vim-fugitive'             " git utils

" movement
NeoBundle 'Lokaltog/vim-easymotion'        " much quicker movement
NeoBundle 'dantler/vim-alternate'          " switch from .c to .h and visa versa

" colorschemes
NeoBundle 'synic/jellybeans.vim'
NeoBundle 'synic/synic.vim'
" NeoBundle 'synic/jedit.vim'
NeoBundle 'altercation/vim-colors-solarized'

call neobundle#end()

filetype plugin on
filetype plugin indent on

NeoBundleCheck          " see if we need to install plugins

set bs=2		        " allow backspacing over everything in insert mode
set ai			        " always set autoindenting on
set nobackup	        " don't keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			            " than 50 lines of registers
set history=50		    " keep 50 lines of command line history
set ruler		        " show the cursor position all the time
set nowrap              " make sure that long lines don't wrap
set laststatus=2        " Make sure the status line is always displayed
set spell               " turn on spellcheck
set splitright
set splitbelow
set nohlsearch
set visualbell

command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" Switch syntax highlighting on
syntax enable

" Display bufnr:filetype (dos,unix,mac) in status line
set statusline=%<%n:%f%h%m%r%=\ %{&ff}\ %l,%c%V\ %P

" Turn on mouse support
set mousehide
set nomousefocus
set mousemodel=extend
set mouse=a

" Show paren matches
" For 5 tenths of a second
set showmatch
set matchtime=5

" Setup tabs for 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
" set smarttab
set shiftround
set expandtab
set noautoindent

" Setup auto wrapping
set textwidth=78

map <F2> :BufExplorer<CR>
map <F10> :NERDTreeToggle<CR>

set hidden

set noequalalways
set dir=~/.vim/swap
set nobackup writebackup

try
    colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme ron
endtry

set colorcolumn=80
set number

" setup custom tab lines with numbers and the close button
function CustomTabLine()
    let s = ''
    let i = 0
    let t = tabpagenr()
    while i < tabpagenr('$')
        let buflist = tabpagebuflist(i + 1)
        let winnr = tabpagewinnr(i + 1)
        " select the highlighting
        if (i + 1) == t
            let s .= '%#TabLineSel#'
        else:
            let s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'
        let s .= '['
        let file = bufname(buflist[winnr - 1])
        let file = fnamemodify(file, ':p:t')
        if file == ''
            let file = 'x'
        endif
        let s .= i . ':' . file

        let s .= ']'

        let i = i + 1
    endwhile

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999XX'
    endif

    return s
endfunction

set tabline=%!CustomTabLine()

" set up hlsearch toggling with F4 as the hotkey
:noremap <F4> :set hlsearch! hlsearch?<CR>

" fugitive
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gr :Gread<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>ge :Gedit<CR>

" Mnemonic _i_nteractive
nnoremap <silent> <leader>gi :Git add %<CR>
nnoremap <silent> <leader>gg :SignifyToggle<CR>

" tablist
let Tlist_Show_One_File = 1
let Tlist_Use_Horiz_Window = 1
let Tlist_Enable_Fold_Column = 0

" nerdtree
let NERDTreeIgnore=['\.pyc$', '\.pyo$', '\.db$', '\.o$', '\.d$', '\.elf$', '\.map$']
let NERDTreeShowBookmarks=1
let NERDTreeMinimalUI=1
let NERDTreeWinSize=25
let NERDTreeChDirMode=2

" gundo settings
let g:gundo_width=35
let g:gundo_right=1
let g:gundo_preview_height=25
nnoremap <F5> :GundoToggle<CR>

" jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = "0"

" tell jedi not to show docstrings when autocompleting
autocmd FileType python setlocal completeopt-=preview

" arduino syntax setup
au BufRead,BufNewFile *.pde set filetype=arduino
au BufRead,BufNewFile *.ino set filetype=arduino

" ultisnips settings
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'UltiSnips.Local'
    \ ]

" bufexplorer
let g:bufExplorerSortBy = 'mru'

" syntasic
let g:syntastic_check_on_open = 1 " check on open and on write
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_loc_list_height = 5
nnoremap <leader>s :SyntasticCheck<CR>

function! <SID>LocationPrevious()
  try
    lprev
  catch /^Vim\%((\a\+)\)\=:E553/
    llast
  endtry
endfunction

function! <SID>LocationNext()
  try
    lnext
  catch /^Vim\%((\a\+)\)\=:E553/
    lfirst
  endtry
endfunction

nnoremap <silent> <Plug>LocationPrevious :<C-u>exe 'call <SID>LocationPrevious()'<CR>
nnoremap <silent> <Plug>LocationNext :<C-u>exe 'call <SID>LocationNext()'<CR>
nmap <silent> ,, <Plug>LocationPrevious
nmap <silent> .. <Plug>LocationNext

" rope
let g:ropevim_guess_project = 1

" Gist
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1

" easy motion
nmap <Leader>l <Plug>(easymotion-lineforward)
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)
nmap <Leader>h <Plug>(easymotion-linebackward)
nmap <Leader>w <Plug>(easymotion-w)
nmap <Leader>W <Plug>(easymotion-W)
nmap <Leader>b <Plug>(easymotion-b)
nmap <Leader>B <Plug>(easymotion-B)

let g:EasyMotion_startofline = 1 " don't keep cursor column when JK motion

" Ctrl-P

set wildignore=*.pyc,*.eot,*.svg,*.ttf,*.woff,*.png,*.jpg,*.gif

nnoremap <silent> <leader>R :CtrlPClearCache<CR>:CtrlP<CR>

" localvimrc
let g:localvimrc_whitelist="/Users/synic/Projects/eventboard.io/.*"

" solarized
let g:solarized_termcolors=256
