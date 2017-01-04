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
NeoBundle 'vim-scripts/openssl.vim'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'mhinz/vim-startify'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/vimproc.vim', {
            \ 'build' : {
            \     'windows' : 'tools\\update-dll-mingw',
            \     'cygwin' : 'make -f make_cygwin.mak',
            \     'mac' : 'make',
            \     'linux' : 'make',
            \     'unix' : 'gmake',
            \    },
            \ }

" project management
NeoBundle 'godlygeek/tabular'              " align text, even tables
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'dbakker/vim-projectroot'

" window management
NeoBundle 'zhaocai/GoldenView.Vim'

" file management
NeoBundle 'dkprice/vim-easygrep'

" coding
NeoBundle 'pangloss/vim-javascript'        " javascript utils
NeoBundle 'SirVer/ultisnips'               " textmate style snippets
NeoBundle 'honza/vim-snippets'             " the actual snippest themselves
NeoBundle 'tpope/vim-surround'             " add, change, delete surround text
NeoBundle 'scrooloose/syntastic'           " syntax checking
NeoBundle 'Valloric/ListToggle'
NeoBundle 'jmcantrell/vim-virtualenv'      " virtualenv
NeoBundle 'ntpeters/vim-better-whitespace' " removes spurious whitespace
NeoBundle 'tpope/vim-commentary'

" syntax files
NeoBundle 'plasticboy/vim-markdown'        " markdown syntax highlighting
NeoBundle 'gorodinskiy/vim-coloresque'     " highlight color codes in CSS

" undo
NeoBundle 'sjl/gundo.vim'                  " undo tree

" git
NeoBundle 'mattn/webapi-vim'               " required for gist-vim
NeoBundle 'mattn/gist-vim'                 " post gists to gist.github.com
NeoBundle 'tpope/vim-fugitive'             " git utils
NeoBundle 'airblade/vim-gitgutter'

" movement
NeoBundle 'Lokaltog/vim-easymotion'        " much quicker movement
NeoBundle 'vim-scripts/quit-another-window'

" colorschemes
NeoBundle 'synic/jellybeans.vim'
NeoBundle 'synic/synic.vim'

call neobundle#end()

filetype plugin on
filetype plugin indent on

NeoBundleCheck          " see if we need to install plugins

set bs=2                " allow backspacing over everything in insert mode
set cindent
set si
set nobackup            " don't keep a backup file
set viminfo='20,\"50    " read/write a .viminfo file
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set nowrap              " make sure that long lines don't wrap
set laststatus=2        " Make sure the status line is always displayed
set spell               " turn on spellcheck
set splitright
set splitbelow
set visualbell
set incsearch
set wildmenu
set wildmode=longest:full,full

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
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost .gvimrc source %

" switch syntax highlighting on
syntax enable

" try to enable jellybeans theme, but if that fails, choose `ron`
try
    colorscheme jellybeans
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
source $VIMHOME/unite.vim
source $VIMHOME/functions.vim
source $VIMHOME/keybindings.vim
