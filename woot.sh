#!/bin/sh

rm -rf ~/.vim
cd ..
mv vim ~/.vim

ln -sf .vim/.vimrc
ln -sf .vim/.gvimrc
