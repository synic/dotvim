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

" VIM Specific settings
filetype plugin on
filetype plugin indent on

let mapleader=","
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
set equalalways         " keep windows equalized

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

" line numbering
set number

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

" keep selection after indent
vnoremap < <gv
vnoremap > >gv

" remap escape key
inoremap fd <esc>
vnoremap fd <esc>

" movement
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
nmap <silent> <space>w= <C-w>=
nmap <silent> <space>wJ :Qj<cr>
nmap <silent> <space>wH :Qh<cr>
nmap <silent> <space>wK :Qk<cr>
nmap <silent> <space>wL :Ql<cr>

" configuration management
nmap <silent> <space>fed :e $VIMHOME/<cr>

" netrw configuration
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide =
    \ '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

" open netrw in the current file's directory
function! NetRWCurrentFile()
    let pathname = expand('%:p:h')
    execute 'edit ' . pathname
endfunction

map - :call NetRWCurrentFile()<cr>
nmap <silent> <space>ob 1<C-g>:<C-U>echo v:statusmsg<CR>

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

try
    colorscheme gruvbox
    set background=dark
    hi ColorColumn guibg=#303030 ctermbg=236
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry

if has('nvim')
  lua require('init')
else

  " load plugins
  source $VIMHOME/config/plugins.vim
  colorscheme gruvbox

  " automatically reload vimrc and gvimrc on save
  autocmd! bufwritepost vimrc source %
  autocmd! bufwritepost gvimrc source %

  " load scripts
  source $VIMHOME/config/pluginsettings.vim      " plugin specific settings
  source $VIMHOME/config/functions.vim           " user-defined functions
  source $VIMHOME/config/keybindings.vim         " custom keybindings
  source $VIMHOME/config/autocmds.vim            " auto commands
end
