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

" automatically reload .vimrc and .gvimrc on save
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost .gvimrc source %

" set setting variables
let g:golden_ratio_enabled = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                          Custom Functions                               """
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CopyBuffer()
    " yank entire buffer into clipboard
    let cursor_pos = getpos('.')
    normal ggVGy
    call setpos('.', cursor_pos)
endfunction

function! GrepProject()
    let pathname = ProjectRootGuess()
    call inputsave()
    let keywords = input('Search: ')
    call inputrestore()
    if empty(keywords)
        return
    endif
    execute ':GrepRoot ' . pathname
    execute ':Grep ' . keywords
endfunction

function! GrepProjectCurrentDir()
    let pathname = expand('%:p:h')
    call inputsave()
    let keywords = input('Search: ')
    call inputrestore()
    if empty(keywords)
        return
    endif
    execute ':GrepRoot ' . pathname
    execute ':Grep ' . keywords
endfunction

function! SearchAndReplaceInProject()
    let pathname = ProjectRootGuess()()
    call inputsave()
    let replace = input('Replace: ')
    if empty(replace)
        call inputrestore()
        return
    endif
    let what = input('With: ')
    call inputrestore()

    if empty(what)
        return
    endif
    execute ':GrepRoot ' . pathname
    execute ':Grep ' . keywords
endfunction

function! JoinSpaceless()
    execute 'normal gJ'

    " Character under cursor is whitespace?
    if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
        " When remove it!
        execute 'normal dw'
    endif
endfunction

function! SessionSavePrompt()
    call inputsave()
    let name = input('Session name: ')
    if empty(name)
        return
    endif
    call inputrestore()
    execute ':SSave ' . name
endfunction

function! SessionDeletePrompt()
    call inputsave()
    let name = input('Session name: ')
    if empty(name)
        return
    endif
    call inputrestore()
    execute ':SDelete ' . name
endfunction

function! ToggleComment()
    if mode() !~# "^[vV\<C-v>]"
        " not visual mode
        normal gcc
    else
        visual gc
    endif
endfunction

function! TabLine()
    let s = ''
    let i = 0
    let t = tabpagenr()
    while i < tabpagenr('$')
        let buflist = tabpagebuflist(i + 1)
        let winnr = tabpagewinnr(i + 1)
        " select the highlighting
        if (i + 1) == t
            let s .= '%#TabLineSel#'
        else
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

function! NetRWCurrentFile()
    let pathname = expand('%:p:h')
    execute 'edit ' . pathname
endfunction

function! NetRWCurrentProject()
    let pathname = ProjectRootGuess()()
    execute 'edit ' . pathname
endfunction

function! NumberToggle()
  if(&relativenumber == 1)
    set number
    set norelativenumber
  else
    set relativenumber
  endif
endfunc

function! WindowCommand(cmd)
    execute a:cmd
    if g:golden_ratio_enabled == 0
        normal <C-w>=
    endif
endfunction

function! ToggleGoldenRatio()
    execute ':ToggleGoldenViewAutoResize'
    if g:golden_ratio_enabled == 0
        let g:golden_ratio_enabled = 1
    else
        let g:golden_ratio_enabled = 0
    endif
endfunction

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" Change the leader key to spacebar
let mapleader = '\<space>'

" Toggle relative line numbering
nmap <space>tr :call NumberToggle()<cr>

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
set shiftround
set expandtab
set noautoindent

" Setup auto wrapping
set textwidth=78
set hidden
set colorcolumn=80
set number
set noequalalways
set dir=~/.vim/swap
set nobackup writebackup

" try to enable jellybeans theme, but if that fails, choose `ron`
try
    colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme ron
endtry

" map the escape key to `fd`
imap fd <Esc>
vmap fd <Esc>

" setup custom tab lines with numbers and the close button
set tabline=%!TabLine()

" set up hlsearch toggling with F4 as the hotkey
:noremap <F4> :set hlsearch! hlsearch?<cr>

" fugitive
nnoremap <silent> <leader>gs :Gstatus<cr>
nnoremap <silent> <leader>gd :Gdiff<cr>
nnoremap <silent> <leader>gc :Gcommit<cr>
nnoremap <silent> <leader>gb :Gblame<cr>
nnoremap <silent> <leader>gl :Glog<cr>
nnoremap <silent> <leader>gp :Git push<cr>
nnoremap <silent> <leader>gr :Gread<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>ge :Gedit<cr>
nnoremap <silent> <leader>gi :Git add %<cr>
nnoremap <silent> <leader>gg :SignifyToggle<cr>

" commenting
nmap <space>cl :call ToggleComment()<cr>
vmap <space>cl :call ToggleComment()<cr>

" gundo settings
let g:gundo_width=35
let g:gundo_right=1
let g:gundo_preview_height=25
nnoremap <F5> :GundoToggle<cr>

" jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 1
let g:jedi#smart_auto_mappings = 0
" autocmd FileType python setlocal completeopt-=preview

" ultisnips settings
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'UltiSnips.Local'
    \ ]

" bufexplorer
let g:bufExplorerSortBy = 'mru'

" easy window switching
nmap <silent> <space>wk :wincmd k<cr>
nmap <silent> <space>wj :wincmd j<cr>
nmap <silent> <space>wh :wincmd h<cr>
nmap <silent> <space>wl :wincmd l<cr>
nmap <silent> <space><tab> :b#<cr>
nmap <silent> <space>w/ :call WindowCommand(':vs')<cr>
nmap <silent> <space>w- :call WindowCommand(':sp')<cr>
nmap <silent> <space>wc :call WindowCommand(':close')<cr>
nmap <silent> <space>wd :call WindowCommand(':q')<cr>
nmap <silent> <space>w= <C-w>=
nmap <silent> <space>wJ :call WindowCommand(':Qj')<cr>
nmap <silent> <space>wH :call WindowCommand(':Qh')<cr>
nmap <silent> <space>wK :call WindowCommand(':Qk')<cr><C-w>=
nmap <silent> <space>wL :call WindowCommand(':Ql')<cr><C-w>=
nmap <silent> <space>fed :e ~/.vimrc<cr>

" syntasic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_check_on_open = 1 " check on open and on write
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_loc_list_height = 7
let g:syntastic_python_checker_args = "--ignore=E501,W601,D100"
let g:lt_location_list_toggle_map = '<space>el'
let g:syntastic_mode_map = {'mode': 'active'}
nnoremap <space>ss :SyntasticCheck<cr>

" rope
let g:ropevim_guess_project = 1

" git
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1
let g:magit_show_help = 0
map <space>gr :Gist<cr>
map <space>gs :call magit#show_magit('h')<cr>
nmap <space>gb :Gblame<cr>
nmap <space>ga :Gadd<cr>
nmap <space>gl :Glog<cr>

" easy motion
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
map <space><space> <plug>(easymotion-bd-f)
nmap <space><space> <plug>(easymotion-overwin-f)

let g:EasyMotion_startofline = 1 " don't keep cursor column when JK motion

" CtrlP
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,__pycache__,*.rst,*.png,*.jpg,node_modules,globalstatic,dumps,*.pyc,build
let g:ctrlp_custom_ignore = {
    \ 'dir':  '(\.svn|\.git|\.hg|node_modules|globalstatic|dumps|sql)$',
    \ 'file': '\v\.(exe|so|dll|dat)$',
    \ 'link': 'some_bad_symbolic_links',
    \ }
let g:ctrlp_map = '<space>ph'
let g:ctrlp_command = 'CtrlPMixed'
let g:ctrlp_max_files = 80000
let g:ctrlp_match_window = 'bottom,order:ttb,min:10,max:10,results:10'
map <space>bb :CtrlPBuffer<cr>

" startify
let g:startify_custom_header = [
    \ '    \ \   / /_ _|  \/  |',
    \ ' ____\ \ / / | || |\/| |_____',
    \ '|_____\ V /  | || |  | |_____|',
    \ '       \_/  |___|_|  |_|',
    \ ]
nmap <space>bh :Startify<cr>
let g:startify_bookmarks = [
    \ {'eventboard.io': '~/Projects/eventboard.io'},
    \ {'skedup': '~/Projects/skedup'},
    \ ]
let g:startify_list_order = ['bookmarks', 'files', 'sessions']

" Searching, etc
nmap <space>sp :call GrepProject()<cr>
nmap <space>sd :call GrepProjectCurrentDir()<cr>
nmap <space>sr :call SearchAndReplaceInProject()<cr>

let g:EasyGrepSearchCurrentBufferDir = 0
let g:EasyGrepRecursive = 1
let g:EasyGrepCommand = 1
if executable('ag')
    set grepprg=ag\ --vimgrep\ --ignore\ "*.sql"\ --ignore\ "*.dat"\ --ignore\ "*.png" --ignore-dir\ node_modules\ --ignore-dir\ globalstatic\ \$*
endif

" Misc
map yig :call SelectBuffer()<cr>
map vig ggVG

nnoremap J :call JoinSpaceless()<cr>

" file management
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'
map - :call NetRWCurrentFile()<cr>
map _ :call NetRWCurrentProject()<cr>

" sessions
map <space>ls :call SessionSavePrompt()<cr>
map <space>ld :call SessionDeletePrompt()<cr>

" golden ratio
let g:goldenview__enable_at_startup = 0
let g:goldenview__enable_default_mapping = 0

map <space>tg :call ToggleGoldenRatio()<cr>
