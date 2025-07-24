-- Basic settings
vim.opt.number = true							-- Line numbers
vim.opt.relativenumber = true					-- Relative line numbers
vim.opt.cursorline = true						-- Highlight current line
vim.opt.wrap = false							-- Don't wrap lines
vim.opt.scrolloff = 10							-- Keep 10 lines above/below cursor 
vim.opt.sidescrolloff = 8						-- Keep 8 columns left/right of cursor

vim.o.fileencoding = 'utf-8'					-- the encoding written to a file

vim.opt.smartindent = true						-- Smart auto-indenting
vim.opt.autoindent = true						-- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true						-- Case insensitive search
vim.opt.smartcase = true						-- Case sensitive if uppercase in search
vim.opt.hlsearch = false						-- Don't highlight search results 
vim.opt.incsearch = true						-- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true					-- Enable 24-bit colors
vim.opt.signcolumn = "yes"						-- Always show sign column
vim.opt.colorcolumn = "100"						-- Show column at 100 characters
vim.opt.showmatch = true						-- Highlight matching brackets

-- Split behavior
vim.opt.splitbelow = true						-- Horizontal splits go below
vim.opt.splitright = true						-- Vertical splits go right

vim.wo.number = true							-- Make line numbers default
vim.o.mouse = 'a'								-- Enable mouse mode
vim.o.clipboard = 'unnamedplus'					-- Sync clipboard between OS and Neovim.
vim.o.breakindent = true						-- Enable break indent
vim.o.undofile = true							-- Save undo history

vim.o.smartcase = true							-- smart case
vim.o.shiftwidth = 4							-- the number of spaces inserted for each indentation
vim.o.tabstop = 4								-- insert n spaces for a tab
vim.o.softtabstop = 4							-- Number of spaces that a tab counts for while performing editing operations
vim.o.expandtab = false							-- convert tabs to spaces

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

