call pathogen#infect()
set background=dark     " Assume a dark background
let g:solarized_termtrans = 1
"colorscheme solarized
set mouse=a                 " automatically enable mouse usage
scriptencoding utf-8
set history=1000 
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " backspace and cursor keys wrap to
set nowrap                      " wrap long lines
set autoindent                  " indent at the same level of the previous line
set shiftwidth=4                " use indents of 4 spaces
"set expandtab                   " tabs are spaces, not tabs
set tabstop=4                   " an indentation every four columns
set softtabstop=4               " let backspace delete indent
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set nocompatible
syntax enable
set incsearch
set hlsearch
filetype plugin indent on
