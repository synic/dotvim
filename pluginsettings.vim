" install vim-plug if it's not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | Startify | Ql
endif

" golden ratio
let g:golden_ratio_enabled = 0
let g:golden_ratio_autocommand = 0

" incsearch
let g:incsearch#auto_nohlsearch = 1

" setup custom tab lines with numbers and the close button
" set tabline=%!TabLine()

" gundo settings
let g:gundo_width = 35
let g:gundo_right = 1
let g:gundo_preview_height = 25

" youcomplete
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']

" supertab
let g:SuperTabDefaultCompletionType = '<C-j>'

" jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 1
let g:jedi#smart_auto_mappings = 0
let g:jedi#goto_definitions_command = 'gd'
let g:jedi#completions_command = '<C-n>'

" ultisnips settings
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'ultisnippets'
    \ ]
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" listtoggle
let g:lt_location_list_toggle_map = '<space>el'

" ale
let g:ale_python_flake8_executable = 'python3'
let g:ale_python_flake8_args = '-m flake8'
let g:ale_sign_column_always = 1

" rope
let g:ropevim_guess_project = 1

" git
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 0
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1

let g:gitgutter_sign_column_always = 1

let g:magit_show_help = 0

" easy motion
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
let g:EasyMotion_startofline = 1 " don't keep cursor column when JK motion

" CtrlP
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,__pycache__,*.rst,*.png,*.jpg,node_modules,globalstatic,dumps,*.pyc,build
let g:ctrlp_custom_ignore = {
    \ 'dir':  '(\.svn|\.git|\.hg|node_modules|globalstatic|dumps|sql|build|dist|docs)$',
    \ 'file': '\v\.(exe|so|dll|dat)$',
    \ 'link': 'some_bad_symbolic_links',
    \ }
let g:ctrlp_map = '<space>ph'
let g:ctrlp_command = 'CtrlPMixed'
let g:ctrlp_max_files = 80000
let g:ctrlp_match_window = 'bottom,order:ttb,min:10,max:10,results:10'

if executable('ag')
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_use_caching = 1

    let g:ctrlp_grep_ignore = '\(\.rst\|\.jpg\|\.png\|node_modules\)$'
    let g:ctrlp_fallback = 'ag %s --nocolor -l -g ""'

    let g:ctrlp_user_command = {
            \ 'types': {
                \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others | grep -v "' . g:ctrlp_grep_ignore . '"'],
                \ 2: ['.hg', 'hg --cwd %s locate -I . | grep -v "' . g:ctrlp_grep_ignore . '"'],
            \ },
            \ 'fallback': g:ctrlp_fallback
        \ }
endif

" startify
let g:startify_custom_header = [
    \ '    \ \   / /_ _|  \/  |',
    \ ' ____\ \ / / | || |\/| |_____',
    \ '|_____\ V /  | || |  | |_____|',
    \ '       \_/  |___|_|  |_|',
    \ ]

if filereadable(expand('~/.cache/startify_bookmarks.vim'))
    source ~/.cache/startify_bookmarks.vim
else
    let g:startify_bookmarks = [
        \ {'eventboard.io': '/Users/synic/Projects/eventboard.io'},
        \ {'skedup': '/Users/synic/Projects/skedup'},
        \ ]
endif

let g:startify_list_order = ['bookmarks', 'files', 'sessions']
let g:startify_change_to_dir = 1
let g:startify_fortune_use_unicode = 0
let g:startify_enable_special = 0

" file management
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

" nerdtree
let NERDTreeIgnore = ['__pycache__', '\.pyc$', '\.pyo$', '\.db$', '\.o$', '\.d$', '\.elf$', '\.map$']
let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 25
let NERDTreeChDirMode = 2
let NERDTreeHijackNetrw = 0

" ctrlsf
let g:better_whitespace_filetypes_blacklist=['ctrlsf']

" airline/powerline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#tab_min_count = 1
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tab_type = 0

" auto-reload this file when saving
autocmd! bufwritepost pluginsettings.vim source %
