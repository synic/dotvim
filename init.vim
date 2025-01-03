""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                           __     _____ __  __                              "
"                           \ \   / /_ _|  \/  |                             "
"                            \ \ / / | || |\/| |                             "
"                             \ V /  | || |  | |                             "
"                              \_/  |___|_|  |_|                             "
"                                                                            "
"                          synic's vim configuration.                        "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" skip init for vim-tiny or vim-small
if 0 | endif

let $VIMHOME = has('nvim') ? stdpath('config') : expand('<sfile>:p:h')

vnoremap < <gv
vnoremap > >gv
nnoremap vig ggVG
nnoremap yig ggVGy

filetype plugin on
filetype plugin indent on

let mapleader="\<space>" " must be double quotes, don't change
let maplocalleader=','
set backspace=2          " allow backspacing over everything in insert mode
set cindent
set smartindent
set noautoindent
set nobackup             " don't keep a backup file
set viminfo='20,\"50     " read/write a .viminfo file
set history=50           " keep 50 lines of command line history
set ruler                " show the cursor position all the time
set nowrap               " make sure that long lines don't wrap
set splitright
set splitbelow
set visualbell           " use a visual bell instead of beeping
set incsearch            " use incremental search
set wildmenu
set wildmode=longest:full,full
set nohlsearch
set equalalways          " keep windows equalized
set nowritebackup
set nobackup
set noswapfile
set autoread
set nocursorbind
set noscrollbind
set hidden
set completeopt=menu,menuone,noselect
set shortmess+=I
set encoding=utf-8
set scrolloff=15
" set iskeyword-=_
set cursorline
set listchars=tab:\|\ ,eol:↵

" enable comprehensive session saving
set sessionoptions+=winpos,globals,localoptions,options

" display bufnr:filetype (dos,unix,mac) in status line
set statusline=%<%n:%f%h%m%r%=\ %{&ff}\ %l,%c%V\ %P

" turn on mouse support
set mousehide
set nomousefocus
set mousemodel=extend
set mouse=a

" enable modeline support
set modeline
set modelines=5

" show paren matches for 5 tenths of a second
set showmatch
set matchtime=5

" ignore case when searching by default
set ignorecase
set smartcase

" setup tabs for 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab

" setup auto wrapping
set textwidth=78
set formatoptions+=t
set colorcolumn=0

" line numbering
set number

" attempt to create swap directory if it doesn't exist
silent !mkdir $VIMHOME/swap > /dev/null 2>&1
set dir=$VIMHOME/swap
set nobackup nowritebackup

" enable putting without yanking (ie, if you put over another line)
xnoremap <expr> p 'pgv"'.v:register.'y`>'

" enable project specific vim settings
set exrc
set secure

" automatically check to see if files have changed
au CursorHold * if getcmdwintype() == '' | checktime | endif
au FocusGained,BufEnter * if getcmdwintype() == '' | checktime | endif
au FocusLost,WinLeave * if getcmdwintype() == '' | checktime | endif

" switch syntax highlighting on
syntax enable

" enable system clipboard by default
set clipboard=unnamed

" if using a mac, set LC_CTYPE if it's not already
if has('macunix') && empty($LC_CTYPE)
	let $LC_CTYPE = 'en_US.UTF-8'
endif

if has('vim_starting')
	if &compatible
		set nocompatible " disable vi settings
	endif
endif

if has('termguicolors')
	set termguicolors
end

if has('nvim')
	lua require('ao')
else
	source $VIMHOME/vim/config.vim
end
