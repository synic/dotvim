setlocal colorcolumn=79
setlocal foldmethod=marker
setlocal iskeyword=@,48-57,_,192-255

au BufWritePre *.py call TrimEndLines()
