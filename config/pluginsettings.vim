" VIM Plugin Specific Settings
" Use `zR` to open all folds

" ### roman/golden-ratio {{{1
"----------------------------------------------------------------------------"
let g:golden_ratio_enabled = 0
let g:golden_ratio_autocommand = 0

" ### haya14busa/incsearch.vim {{{1
"----------------------------------------------------------------------------"
let g:incsearch#auto_nohlsearch = 1

" ### Gsjl/gundo.vim {{{1
"----------------------------------------------------------------------------"
let g:gundo_width = 35
let g:gundo_right = 1
let g:gundo_preview_height = 25

" ### davidhalter/jedi-vim {{{1
"----------------------------------------------------------------------------"
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#goto_definitions_command = 'gd'
let g:jedi#completions_command = '<C-n>'

" ### SirVer/ultisnips {{{1
"----------------------------------------------------------------------------"
let g:UltiSnipsSnippetDirectories = [
    \ $HOME.'/.vim/bundle/vim-snippets/UltiSnips',
    \ 'snips'
    \ ]
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" ### Valloric/ListToggle {{{1
"----------------------------------------------------------------------------"
let g:lt_location_list_toggle_map = '<space>el'

" ### w0rp/ale {{{1
"----------------------------------------------------------------------------"
let g:ale_sign_column_always = 1

" ### python-rope/ropevim {{{1
"----------------------------------------------------------------------------"
let g:ropevim_guess_project = 1

" ### mattn/gist-vim {{{1
"----------------------------------------------------------------------------"
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 0
let g:gist_clip_command = 'pbcopy' " for os X
let g:gist_post_private = 1

" ### airblade/vim-gitgutter {{{1
"----------------------------------------------------------------------------"
let g:gitgutter_sign_column_always = 1


" ### ajreybert/vimagit {{{1
"----------------------------------------------------------------------------"
let g:magit_show_help = 0

" ### Lokaltog/vim-easymotion {{{1
"----------------------------------------------------------------------------"
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
let g:EasyMotion_startofline = 1 " don't keep cursor column when JK motion

" ### ctrlpvim/ctrlp.vim {{{1
"----------------------------------------------------------------------------"
" enable buffer deletion plugin
call ctrlp_bdelete#init()

let ctrlp_dir_ignore =
    \ '(\.svn|\.git|\.hg|node_modules|globalstatic|dumps|sql|build|dist|docs)$'
let g:ctrlp_custom_ignore = {
        \ 'dir': ctrlp_dir_ignore,
    \ }
let g:ctrlp_command = 'CtrlPMixed'
let g:ctrlp_max_files = 80000
let g:ctrlp_match_window = 'bottom,order:ttb,min:10,max:10,results:10'
let ctrlp_git_ls_command =
    \ 'cd %s && git ls-files . --cached --exclude-standard'
let ctrlp_hg_ls_command = 'hg --cwd %s locate -I .'

if executable('ag')
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_use_caching = 0

    let g:ctrlp_grep_ignore = '\(\.rst\|\.jpg\|\.png\|node_modules\)$'
    let g:ctrlp_fallback = 'ag %s --nocolor -l -g ""'

    let g:ctrlp_user_command = {
            \ 'types': {
                \ 1: ['.git', ctrlp_git_ls_command],
                \ 2: ['.hg', ctrlp_hg_ls_command],
            \ },
            \ 'fallback': g:ctrlp_fallback
        \ }
endif

" ### mhinz/vim-startify {{{1
"----------------------------------------------------------------------------"
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

" ### netrw {{{1
"----------------------------------------------------------------------------"
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_list_hide =
    \ '\(^\|\s\s\)\zs\.\S\+,\(^\|\s\s\)ntuser\.\S\+,__pycache__,\.pyc'

" ### scrooloose/nerdtree {{{1
"----------------------------------------------------------------------------"
let NERDTreeIgnore = [
    \ '__pycache__', '\.pyc$', '\.pyo$', '\.db$',
    \ '\.o$', '\.d$', '\.elf$', '\.map$']
let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 25
let NERDTreeChDirMode = 2
let NERDTreeHijackNetrw = 0

" ### dyng/ctrlsf.vim {{{1
"----------------------------------------------------------------------------"
let g:better_whitespace_filetypes_blacklist = ['ctrlsf']
let g:ctrlsf_default_view_mode = 'compact'

" ### bling/vim-airline {{{1
"----------------------------------------------------------------------------"
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tab_type = 0

let g:airline#extensions#whitespace#enabled = 0

" ### jmcantrell/vim-virtualenv {{{1
"----------------------------------------------------------------------------"
let g:virtualenv_auto_activate = 1

" ### python-mode/python-mode {{{1
"----------------------------------------------------------------------------"
let g:pymode_folding = 0
let g:pymode_lint = 0
let g:pymode_rope = 0
let g:pymode_options = 0

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost pluginsettings.vim source %

" vim:foldmethod=marker
