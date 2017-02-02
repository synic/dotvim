function! s:UniteSettings()
  imap <buffer> <C-j> <Plug>(unite_select_next_line)
  imap <buffer> <C-k> <Plug>(unite_select_previous_line)

  nmap <silent><buffer><expr> Enter unite#do_action('switch')
  nmap <silent><buffer><expr> <C-t> unite#do_action('tabswitch')
  nmap <silent><buffer><expr> <C-h> unite#do_action('splitswitch')
  nmap <silent><buffer><expr> <C-v> unite#do_action('vsplitswitch')

  imap <silent><buffer><expr> Enter unite#do_action('switch')
  imap <silent><buffer><expr> <C-t> unite#do_action('tabswitch')
  imap <silent><buffer><expr> <C-h> unite#do_action('splitswitch')
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplitswitch')

  map <buffer> <C-p> <Plug>(unite_toggle_auto_preview)

  let b:actually_quit = 0
  setlocal updatetime=3
  au! InsertEnter <buffer> let b:actually_quit = 0
  au! InsertLeave <buffer> let b:actually_quit = 1
  au! CursorHold  <buffer> if exists('b:actually_quit') && b:actually_quit | close | endif
endfunction

" unite
if executable('ag')
  let g:unite_source_rec_async_command = 'ag --follow --nocolor --nogroup --hidden -g ""'
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nocolor --nogroup'
  let g:unite_source_grep_recursive_opt = ''
endif
let g:unite_update_time = 500
let g:unite_source_rec_unit = 250
let g:unite_source_rec_max_cache_files = 0
let g:unite_source_history_yank_enable = 1
let g:unite_enable_start_insert = 1
let g:unite_enable_auto_select = 1
let g:unite_split_rule = 'bot'
let g:unite_source_rec_async_command = ['ag', '-l', '-g', '', '--nocolor', '--python']
let g:unite_source_alias_aliases = {
    \ 'files': 'file_rec/async',
    \ 'buffers': 'buffer',
    \ 'mru': 'file_mru',
    \ }

if exists(':Unite')
    autocmd FileType unite call s:UniteSettings()
    call unite#filters#matcher_default#use(['matcher_fuzzy', 'matcher_hide_hidden_files'])
    call unite#custom#source('buffer', 'matchers', ['matcher_fuzzy'])
    call unite#filters#sorter_default#use(['sorter_rank'])

    call unite#sources#rec#define()
    call unite#custom#source('file_rec/async,file_mru,file,buffer,grep', 'ignore_pattern', 'node_modules')
    map <space>bb :Unite -toggle -buffer-name=search buffers<cr>
endif

