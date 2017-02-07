""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                           __     _____ __  __                              "
"                           \ \   / /_ _|  \/  |                             "
"                            \ \ / / | || |\/| |                             "
"                             \ V /  | || |  | |                             "
"                              \_/  |___|_|  |_|                             "
"                                                                            "
"                 Adam Olsen's (aka synic) vim configuration.                "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""   Note: skip init for vim-tiny or vim-small
if 0 | endif

if has('vim_starting')
    if &compatible
        set nocompatible " disable vi settings
    endif
endif

" set the correct python path for homebrew if we're on OS X
if has("unix")
    let s:uname = system("echo -n \"$(uname)\"")
    if s:uname == "Darwin"
        python import sys
        python sys.path.insert(0, '/usr/local/lib/python2.7/site-packages')
    endif
endif

" install vim-plug if it's not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | Startify | Ql
endif

" plugin list
call plug#begin('~/.vim/plugged')

" python specific plugins
Plug 'hynek/vim-python-pep8-indent'    " for auto indenting pep8 style
Plug 'python-rope/ropevim'             " refactoring, finding occurrences
Plug 'michaeljsmith/vim-indent-object' " for selecting indent objects

" home screen
Plug 'mhinz/vim-startify'

" project management
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dbakker/vim-projectroot'
Plug 'scrooloose/nerdtree'

" text management
Plug 'godlygeek/tabular'               " align text, even tables

" window management
Plug 'roman/golden-ratio'
Plug 'vim-scripts/tinykeymap'

" coding
Plug 'pangloss/vim-javascript'         " javascript utils
Plug 'SirVer/ultisnips'                " textmate style snippets
Plug 'honza/vim-snippets'              " the actual snippest themselves
Plug 'tpope/vim-surround'              " add, change, delete surround text
Plug 'w0rp/ale'
Plug 'jmcantrell/vim-virtualenv'       " virtualenv
Plug 'ntpeters/vim-better-whitespace'  " removes spurious whitespace
Plug 'tpope/vim-commentary'
Plug 'szw/vim-tags'
Plug 'davidhalter/jedi-vim'            " for code completion

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction

Plug 'Valloric/YouCompleteMe', {'do': function('BuildYCM')}

" search
Plug 'haya14busa/incsearch.vim'
Plug 'dyng/ctrlsf.vim'

" syntax files
Plug 'plasticboy/vim-markdown'         " markdown syntax highlighting

" undo
Plug 'sjl/gundo.vim'                   " undo tree

" git
Plug 'jreybert/vimagit'
Plug 'mattn/webapi-vim'                " required for gist-vim
Plug 'mattn/gist-vim'                  " post gists to gist.github.com
Plug 'tpope/vim-fugitive'              " git utils
Plug 'airblade/vim-gitgutter'

" movement
Plug 'Lokaltog/vim-easymotion'         " much quicker movement
Plug 'vim-scripts/quit-another-window'

" colorschemes
Plug 'synic/jellybeans.vim'
Plug 'jnurmine/Zenburn'
Plug 'morhetz/gruvbox'
Plug 'synic/synic.vim'

" misc
Plug 'vim-scripts/openssl.vim'
Plug 'tpope/vim-unimpaired'
Plug 'Valloric/ListToggle'
Plug 'kshenoy/vim-signature'
Plug 'bling/vim-airline'
Plug 'vim-scripts/Align'

call plug#end()

filetype plugin on
filetype plugin indent on

set bs=2                " allow backspacing over everything in insert mode
set cindent
set si
set nobackup            " don't keep a backup file
set viminfo='20,\"50    " read/write a .viminfo file
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set nowrap              " make sure that long lines don't wrap
set laststatus=2        " Make sure the status line is always displayed
set splitright
set splitbelow
set visualbell
set incsearch
set wildmenu
set wildmode=longest:full,full
set hlsearch

" display bufnr:filetype (dos,unix,mac) in status line
set statusline=%<%n:%f%h%m%r%=\ %{&ff}\ %l,%c%V\ %P

" turn on mouse support
set mousehide
set nomousefocus
set mousemodel=extend
set mouse=a

" show paren matches for 5 tenths of a second
set showmatch
set matchtime=5

" setup tabs for 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab
set noautoindent

" setup auto wrapping
set textwidth=78
set hidden
set colorcolumn=80
set number
set noequalalways
set dir=~/.vim/swap
set nobackup writebackup

" automatically reload .vimrc and .gvimrc on save
autocmd! bufwritepost vimrc source %
autocmd! bufwritepost gvimrc source %

" switch syntax highlighting on
syntax enable

" try to enable jellybeans theme, but if that fails, choose `ron`
try
    colorscheme gruvbox
    set background=dark
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme ron
endtry

" load extra scripts
if has('win32') || has ('win64')
    let $VIMHOME = $VIM . '/vimfiles'
else
    let $VIMHOME = $HOME . '/.vim'
endif
source $VIMHOME/pluginsettings.vim
source $VIMHOME/functions.vim
source $VIMHOME/keybindings.vim
