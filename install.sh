#!/bin/sh

git submodule init
git submodule update
CWD=`pwd`
cd ~
ln -sf .vim/.vimrc
ln -sf .vim/.gvimr
cd $CWD
