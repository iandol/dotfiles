syntax enable
filetype plugin indent on
set background=dark				" Assume a dark background
colorscheme onedark
set clipboard=unnamedplus		" treat the defaut buffer as + register (system clipboard)
set number
set mouse=a						" automatically enable mouse usage
set encoding=utf-8				" The encoding displayed.
set fileencoding=utf-8			" The encoding written to file.
set history=2000
set ignorecase					" case insensitive search
set smartcase					" case sensitive when uc present
set wildmenu					" show list instead of just completing
set wildmode=list:longest,full	" command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]	" backspace and cursor keys wrap to
set list listchars=tab:»·,trail:· " show EOL spaces, tabs etc.
set nowrap						" wrap long lines
set autoindent					" indent at the same level of the previous line
set shiftwidth=4				" use indents of 2 spaces
"set expandtab					" tabs are spaces, not tabs
set tabstop=4					" an indentation every 4 columns
set softtabstop=4				" let backspace delete indent
set pastetoggle=<F12>			" pastetoggle (sane indentation on pastes)
set nocompatible				" not vi compatible, more features
set ruler						" show ruler
set incsearch					" incremental search
set hlsearch					" highlight search result
" Italics
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
highlight Comment cterm=italic

call plug#begin()
	Plug 'tpope/vim-sensible'
	Plug 'tpope/vim-repeat'
	Plug 'itchyny/lightline.vim'
	Plug 'lambdalisue/suda.vim'
	Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
	Plug 'dmix/elvish.vim', { 'for': 'elvish'}
	Plug 'vim-pandoc/vim-pandoc'
	Plug 'vim-pandoc/vim-pandoc-syntax'
	Plug 'quarto-dev/quarto-vim'
	if has('nvim')
		Plug 'ggandor/leap.nvim'
	endif
call plug#end()

if has('nvim')
	lua require('leap').add_default_mappings()
endif
