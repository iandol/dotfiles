syntax enable
colorscheme onedark
set background=dark           " Assume a dark background
set mouse=a                   " automatically enable mouse usage
set encoding=utf-8            " The encoding displayed.
set fileencoding=utf-8        " The encoding written to file.
set history=1000
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " backspace and cursor keys wrap to
set list listchars=tab:»·,trail:· " show EOL spaces, tabs etc.
set nowrap                      " wrap long lines
set autoindent                  " indent at the same level of the previous line
set shiftwidth=4                " use indents of 2 spaces
"set expandtab                   " tabs are spaces, not tabs
set tabstop=4                   " an indentation every 4 columns
set softtabstop=4               " let backspace delete indent
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set nocompatible                " not vi compatible, more features
set ruler                       " show ruler
set incsearch                   " incremental search
set hlsearch                    " highlight search result
filetype plugin indent on
