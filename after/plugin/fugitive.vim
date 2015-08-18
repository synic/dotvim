if exists('g:loaded_fugitive')
    set statusline=%<%n:%f%h%m%r%=%{fugitive#statusline()}\ %{&ff}\ %l,%c%V\ %P
else
    set statusline=%<%n:%f%h%m%r%=\ %{&ff}\ %l,%c%V\ %P
endif
