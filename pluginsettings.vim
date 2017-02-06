" set setting variables
let g:golden_ratio_enabled = 0

" incsearch
let g:incsearch#auto_nohlsearch = 1

" setup custom tab lines with numbers and the close button
set tabline=%!TabLine()

" gundo settings
let g:gundo_width=35
let g:gundo_right=1
let g:gundo_preview_height=25
nnoremap <F5> :GundoToggle<cr>

" youcomplete
let g:ycm_autoclose_preview_window_after_completion = 1

" jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 1
let g:jedi#smart_auto_mappings = 0

" ultisnips settings
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'UltiSnips.Local'
    \ ]

" listtoggle
let g:lt_location_list_toggle_map = '<space>el'

" ale
let g:ale_sign_column_always = 1

" rope
let g:ropevim_guess_project = 1

" git
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1
let g:magit_show_help = 0
let g:gitgutter_sign_column_always = 1

" easy motion
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1

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

" startify
let g:startify_custom_header = [
    \ '    \ \   / /_ _|  \/  |',
    \ ' ____\ \ / / | || |\/| |_____',
    \ '|_____\ V /  | || |  | |_____|',
    \ '       \_/  |___|_|  |_|',
    \ ]
let g:startify_bookmarks = [
    \ {'eventboard.io': '/Users/synic/Projects/eventboard.io'},
    \ {'skedup': '/Users/synic/Projects/skedup'},
    \ ]
let g:startify_list_order = ['bookmarks', 'files', 'sessions']

let g:EasyGrepSearchCurrentBufferDir = 0
let g:EasyGrepRecursive = 1
let g:EasyGrepCommand = 1
if executable('ag')
    set grepprg=ag\ --vimgrep\ --ignore\ "*.sql"\ --ignore\ "*.dat"\ --ignore\ "*.png" --ignore-dir\ node_modules\ --ignore-dir\ globalstatic\ \$*
endif

" file management
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

" golden ratio
let g:goldenview__enable_at_startup = 0
let g:goldenview__enable_default_mapping = 0

" nerdtree
let NERDTreeIgnore = ['__pycache__', '\.pyc$', '\.pyo$', '\.db$', '\.o$', '\.d$', '\.elf$', '\.map$']
let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 25
let NERDTreeChDirMode = 2
let NERDTreeHijackNetrw = 0

" ctrlsf
let g:better_whitespace_filetypes_blacklist=['ctrlsf']
