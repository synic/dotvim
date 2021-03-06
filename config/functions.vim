" VIM Custom Functions
" Use `zR` to open all folds

" ### CUSTOM VARIABLES {{{1
"----------------------------------------------------------------------------"
let s:last_search_term = ''
let s:current_equalalways = 1

" ### CUSTOM FUNCTIONS {{{1
"----------------------------------------------------------------------------"
" yank entire buffer into clipboard
function! CopyBuffer()
    let cursor_pos = getpos('.')
    normal ggVGy
    call setpos('.', cursor_pos)
endfunction

" open nerdtree at the current project root
function! NERDTreeCurrentProject()
    let pathname = ProjectRootGuess()
    execute ':NERDTree ' . pathname
endfunction

" open nerdtree in the current file's directory
function! NERDTreeCurrentFile()
    let pathname = expand('%:p:h')
    execute ':NERDTree ' . pathname
endfunction

" search in the project root
function! SearchInProjectRoot()
    call inputsave()
    let s:last_search_term = input('Search: ')
    call inputrestore()
    execute ':CtrlSF "' . s:last_search_term . '"'
endfunction

" repeat last search
function! RepeatLastSearch()
    if s:last_search_term != ''
        execute ':CtrlSF "' . s:last_search_term . '"'
    else
        echo 'No search to repeat!'
    endif
endfunction

" save session
function! SessionSavePrompt()
    call inputsave()
    let name = input('Session name: ')
    if empty(name)
        return
    endif
    call inputrestore()
    execute ':SSave ' . name
endfunction

" delete a session
function! SessionDeletePrompt()
    call inputsave()
    let name = input('Session name: ')
    if empty(name)
        return
    endif
    call inputrestore()
    execute ':SDelete ' . name
endfunction

" toggle comments for a block
function! ToggleComment()
    if mode() !~# "^[vV\<C-v>]"
        " not visual mode
        normal gcc
    else
        visual gc
    endif
endfunction

" open netrw in the current file's directory
function! NetRWCurrentFile()
    let pathname = expand('%:p:h')
    execute 'edit ' . pathname
endfunction

" open netrw in the current file's project root
function! NetRWCurrentProject()
    let pathname = ProjectRootGuess()
    execute 'edit ' . pathname
endfunction

" toggle line numbering modes
function! NumberToggle()
  if(&relativenumber == 1)
    set number
    set norelativenumber
  else
    set relativenumber
  endif
endfunc

" toggle golden ratio functionality
function! ToggleGoldenRatio()
    execute ':GoldenRatioToggle'
    if g:golden_ratio_enabled == 0
        let g:golden_ratio_enabled = 1
        echo 'Enabled golden ratio'
    else
        let g:golden_ratio_enabled = 0
        echo 'Disabled golden ratio'
        set equalalways
        wincmd =
    endif
endfunction

" diffing files
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" trim the blank lines at the end of the current file
function! TrimEndLines()
    let save_cursor = getpos('.')
    silent! %s#\($\n\s*\)\+\%$##
    call setpos('.', save_cursor)
endfunction

" Zoom / Restore window.
function! s:ZoomToggle() abort
if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
endif
endfunction
command! ZoomToggle call s:ZoomToggle()

" join lines without inserting spaces
fun! JoinSpaceless()
execute 'normal gJ'

    " Character under cursor is whitespace?
    if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
        " When remove it!
        execute 'normal dw'
    endif
endfun

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving

autocmd! bufwritepost functions.vim source %
" vim:foldmethod=marker
