" VIM non-plugin settings

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

" disable completion preview
set completeopt-=preview

" switch syntax highlighting on
syntax enable

" try to enable jellybeans theme, but if that fails, choose `ron`
try
    colorscheme gruvbox
    set background=dark
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme ron
endtry
