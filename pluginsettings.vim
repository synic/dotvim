" set setting variables
let g:golden_ratio_enabled = 0

" setup custom tab lines with numbers and the close button
set tabline=%!TabLine()

" gundo settings
let g:gundo_width=35
let g:gundo_right=1
let g:gundo_preview_height=25
nnoremap <F5> :GundoToggle<cr>

" jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 1
let g:jedi#smart_auto_mappings = 0

" ultisnips settings
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'UltiSnips.Local'
    \ ]

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

" rope
let g:ropevim_guess_project = 1

" git
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1
let g:magit_show_help = 0

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
    \ {'eventboard.io': '~/Projects/eventboard.io'},
    \ {'skedup': '~/Projects/skedup'},
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


