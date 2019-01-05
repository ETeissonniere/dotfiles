" BEGIN CHEATSHEET
" <C-n>...c : place multiple cursors and edit
" :Explore  : open file explorer (default in vim)
" {i}gt     : go to tab {i}
" gt        : next tab
" gT        : previous tab
" END   CHEATSHEET


set nocompatible                         " be iMproved
filetype off                             " required by Vundle

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'            " Plugin manager
Plugin 'dracula/vim'                     " Match ZSH's and iTerm themes
Plugin 'itchyny/lightline.vim'           " Bottom line style
Plugin 'terryma/vim-multiple-cursors'    " Sublime text's cursors
Plugin 'tomlion/vim-solidity'            " Syntax: solidity
Plugin 'kchmck/vim-coffee-script'        " Syntax: coffeescript

call vundle#end()
filetype plugin indent on                " required by Vundle

syntax on
set number

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

set laststatus=2                         " Lightline colors
set noshowmode                           " Lightline handles this

let g:netrw_banner=  0                   " Explorer: no banner
let g:netrw_browse_split=3               " Explorer: open in ew tab
