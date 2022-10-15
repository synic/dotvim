vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
vim.g.ctrlsf_default_view_mode = "compact"
vim.g.ctrlsf_default_root = "project+wf"
vim.g.ctrlsf_auto_close = {
	normal = 0,
	compact = 1,
}
vim.g.ctrlsf_auto_focus = {
	at = "start",
}

vim.cmd([[
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
]])

vim.keymap.set("n", "<space>*", ":CtrlSF<cr>")
vim.keymap.set("n", "<space>Sp", ":call SearchInProjectRoot()")
vim.keymap.set("n", "<space>rl", ":call RepeatLastSearch()")
