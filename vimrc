set nocompatible                         " be iMproved
filetype off                             " required by Vundle

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'dracula/vim'

call vundle#end()
filetype plugin indent on                " required by Vundle

syntax on
set number
set ruler
set showmode
set title

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set autoindent

set cursorline

set showmatch
set incsearch
set hlsearch

set showcmd

set encoding=UTF-8
set autoread

set noerrorbells                         " Shut your mouth
set ttyfast                              " Optimize for fast coonections
