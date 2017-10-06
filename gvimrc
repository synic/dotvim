" set the font for the gui application
if has('macunix')
    " mac version
    set guifont=Hack:h10
else
    " linux version
    set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 8
endi

" turn off gui-only toolbars, etc
set guioptions=agitc

" use the system clipboard for the default clipboard
set clipboard=unnamed
