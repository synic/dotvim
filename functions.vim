function! CopyBuffer()
    " yank entire buffer into clipboard
    let cursor_pos = getpos('.')
    normal ggVGy
    call setpos('.', cursor_pos)
endfunction

function! GrepProject()
    let pathname = ProjectRootGuess()
    execute ':Unite -toggle -buffer-name=search grep:' . pathname
endfunction

function! GrepProjectCurrentDir()
    let pathname = expand('%:p:h')
    execute ':Unite -toggle -buffer-name=search grep:' . pathname
endfunction

function! NERDTreeCurrentProject()
    let pathname = ProjectRootGuess()
    execute ':NERDTree ' . pathname
endfunction

function! NERDTreeCurrentFile()
    let pathname = expand('%:p:h')
    execute ':NERDTree ' . pathname
endfunction

function! SearchInProjectRoot()
    call inputsave()
    let terms = input('Search: ')
    call inputrestore()
    execute ':CtrlSF "' . terms . '"'
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

function! NewTab()
    call inputsave()
    let name = input('Tab name: ')
    if empty(name)
        return
    endif
    call inputrestore()
    execute ':$tabnew'
    execute ':TabooRename ' . name
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
        let s .= (i + 1) . ':' . file

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
    let pathname = ProjectRootGuess()
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
    if !g:golden_ratio_enabled
       wincmd =
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

function! ProjectFiles()
    execute ':Unite -toggle -buffer-name=files files:' . ProjectRootGuess()
endfunction

function! Buffers()
    execute ':Unite -toggle -buffer-name=buffers buffers'
endfunction

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis
