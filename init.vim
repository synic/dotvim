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
set nohlsearch
set equalalways         " keep windows equalized
set nowritebackup
set nobackup
set noswapfile
set autoread

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
set nobackup nowritebackup

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

" netrw configuration
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide =
      \ '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

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

set background=dark
colorscheme desert

" require basic keybindings
source $VIMHOME/keymap.vim

if has('nvim')
  lua require('init')
  set shada=!,'20,<50,s10,h
else
  " load plugins
  source $VIMHOME/config/plugins.vim

  " automatically reload vimrc and gvimrc on save
  autocmd! bufwritepost vimrc source %
  autocmd! bufwritepost gvimrc source %

  " load scripts
  source $VIMHOME/config/pluginsettings.vim      " plugin specific settings
  source $VIMHOME/config/functions.vim           " user-defined functions
  source $VIMHOME/config/keybindings.vim         " custom keybindings
  source $VIMHOME/config/autocmds.vim            " auto commands

  try
    colorscheme gruvbox-material
    let g:gruvbox_material_background = 'hard'
    hi ColorColumn guibg=#303030 ctermbg=236
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
  endtry
end
