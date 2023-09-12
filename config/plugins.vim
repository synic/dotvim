" Plugin List
" Use `zR` to open all folds

" ### Install vim-plug {{{1
"----------------------------------------------------------------------------"
" install vim-plug if it's not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -sfLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC |  Ql
endif

" ### PLUGIN LIST {{{1
"----------------------------------------------------------------------------"
if !empty(glob('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugins')

  Plug 'Lokaltog/vim-easymotion'         
  Plug 'sainnhe/gruvbox-material'
  Plug 'bling/vim-airline'

  call plug#end()
endif

" ### FOOTER/MODELINE {{{1
"----------------------------------------------------------------------------"
" auto-reload this file when saving
autocmd! bufwritepost plugins.vim source %

" vim:foldmethod=marker
