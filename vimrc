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
if has('unix')
    let s:uname = system('echo -n "$(uname)"')
    if s:uname == 'Darwin'
        python import sys
        python sys.path.insert(0, '/usr/local/lib/python2.7/site-packages')
    endif
endif

" set VIM home diretory depending on the platform
if has('win32') || has ('win64')
    let $VIMHOME = $VIM . '/vimfiles'
else
    let $VIMHOME = $HOME . '/.vim'
endif

" plugins.vim         - list of plugins to install/use
" vimsettings.vim     - vim specific (non-plugin) settings
" pluginsettings.vim  - plugin specific settings
" functions.vim       - user-defined functions
" keybindings.vim     - keybindings
let scripts = [
            \ 'plugins.vim',
            \ 'vimsettings.vim',
            \ 'pluginsettings.vim',
            \ 'functions.vim',
            \ 'keybindings.vim',
            \]

for script in scripts
    " read the script now
    exec ':source $VIMHOME/' . script
    " read the script on save
    exec ':autocmd! bufwritepost ' . script . ' source %'
endfor

" automatically reload vimrc and gvimrc on save
autocmd! bufwritepost vimrc source %
autocmd! bufwritepost gvimrc source %

