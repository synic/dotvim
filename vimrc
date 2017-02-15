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

" skip init for vim-tiny or vim-small
if 0 | endif

" set $VIMHOME so we can load configuration files from the correct place
let $VIMHOME = expand('<sfile>:p:h')

" load plugins
source $VIMHOME/config/plugins.vim

" VIM Specific settings
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
set visualbell          " use a visual bell instead of beeping
set incsearch           " use incremental search
set wildmenu
set wildmode=longest:full,full
set hlsearch            " keep search results highlighted

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
set formatoptions+=t
set hidden
set colorcolumn=80
set number
set relativenumber
set noequalalways
" attempt to create swap directory if it doesn't exist
silent !mkdir $VIMHOME/swap > /dev/null 2>&1  
set dir=$VIMHOME/swap
set nobackup writebackup

" enable project specific vim settings
set exrc
set secure

" disable completion preview
set completeopt-=preview

" switch syntax highlighting on
syntax enable

if has('vim_starting')
    if &compatible
        set nocompatible " disable vi settings
    endif
endif

" try to enable jellybeans theme, but if that fails, choose `ron`
try
    colorscheme gruvbox
    set background=dark
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme ron
endtry

" automatically reload vimrc and gvimrc on save
autocmd! bufwritepost vimrc source %
autocmd! bufwritepost gvimrc source %

" load scripts
source $VIMHOME/config/pluginsettings.vim      " plugin specific settings
source $VIMHOME/config/functions.vim           " user-defined functions
source $VIMHOME/config/keybindings.vim         " custom keybindings
