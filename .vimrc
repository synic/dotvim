set nocompatible " disable vi settings

if has("unix")
  let s:uname = system("echo -n \"$(uname)\"")
  if s:uname == "Darwin"
    python import sys; sys.path.insert(0, '/usr/local/lib/python2.7/site-packages')
    set visualbell
  endif
endif

" Vundle Junk
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'python-rope/ropevim'
Plugin 'mattn/webapi-vim'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'nvie/vim-flake8'
Plugin 'davidhalter/jedi-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'SirVer/ultisnips'
Plugin 'sjl/gundo.vim'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'vim-scripts/openssl.vim'
Plugin 'vim-scripts/taglist.vim'
Plugin 'virtualenv.vim'
Plugin 'scala.vim'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'tpope/vim-surround'
Plugin 'mattn/gist-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'dantler/vim-alternate'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'skammer/vim-css-color'
Plugin 'vim-scripts/EnhCommentify.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'kien/ctrlp.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'honza/vim-snippets'
Plugin 'gorodinskiy/vim-coloresque'
Plugin 'Arduino-syntax-file'
call vundle#end()

filetype plugin on

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

command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" Switch syntax highlighting on
syntax enable

" Display bufnr:filetype (dos,unix,mac) in status line
set statusline=%<%n:%f%h%m%r%=%{fugitive#statusline()}\ %{&ff}\ %l,%c%V\ %P

" Hide the mouse pointer while typing
" The window with the mouse pointer does not automatically become the active window
" Right mouse button extends selections
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
set textwidth=78
set smarttab
set shiftround
set expandtab

" Setup auto wrapping
set textwidth=78

" Setup indenting
set autoindent

map <F2> :BufExplorer<CR>
map <F10> :NERDTreeToggle<CR>

set hidden

set noequalalways
set dir=~/.vim/swap
set nobackup writebackup

if $TERM_PROGRAM =~ 'APPLE'
    colorscheme ron
else
    set t_Co=256
    colorscheme synic
endif
set colorcolumn=80

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

set tabline=%!CustomTabLine()

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
nnoremap <silent> <leader>gi :Git add -p %<CR>
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
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/bundle/vim-snippets/UltiSnips', 'UltiSnips.Local']

" bufexplorer
let g:bufExplorerSortBy = 'mru'
au VimEnter * ToggleStripWhitespaceOnSave

" flake8-vim
autocmd BufWritePost *.py call Flake8()
let g:flake8_show_in_gutter = 1
let g:flake8_cmd = "/usr/local/bin/flake8"

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

set wildignore=*.pyc,*.dat,*/static/CACHE/*,*/media/*,*/bower_components/*
set wildignore+=*/static/js/locales/*,*.eot,*.svg,*.ttf,*.woff,*/local/*
set wildignore+=*/assets/scss/*
