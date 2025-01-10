nnoremap <silent><buffer> q <cmd>cclose<cr>
nnoremap <silent><buffer> <localleader>t <cmd>let &winheight = (&winheight == 10 ? float2nr(winheight(0) * 0.6) : 10)<cr>
