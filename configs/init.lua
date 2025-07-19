-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true							-- Line numbers
vim.opt.relativenumber = true					-- Relative line numbers
vim.opt.cursorline = true						-- Highlight current line
vim.opt.wrap = false							-- Don't wrap lines
vim.opt.scrolloff = 10							-- Keep 10 lines above/below cursor 
vim.opt.sidescrolloff = 8						-- Keep 8 columns left/right of cursor

vim.o.fileencoding = 'utf-8' -- the encoding written to a file

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
vim.opt.showmatch = true									-- Highlight matching brackets

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

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"nvim-treesitter/nvim-treesitter", 
			build = ":TSUpdate"
		},
		{
			"catppuccin/nvim",
			lazy = false,
			name = "catppuccin",
			priority = 1000,
			config = function() vim.cmd.colorscheme "catppuccin-mocha" end
		},
		{
			"lambdalisue/suda.vim",
			lazy = false,
		},
		{
			'nvim-telescope/telescope.nvim', tag = '0.1.8',
			dependencies = { 'nvim-lua/plenary.nvim' },
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
				"folke/snacks.nvim",
			},
			opts = {
				window = { position = "right", },
			},
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{
				"<leader>?",
				function() require("which-key").show({ global = true }) end, 
				desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- automatically check for plugin updates
	checker = { enabled = true },
})

require('telescope').setup {
	defaults = { scroll_strategy = "cycle", },
	pickers = { find_files = { follow = true } }
}
local builtin = require('telescope.builtin')
local km = vim.keymap
km.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
km.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
km.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
km.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
km.set('n', '<leader>n', ':Neotree<cr>', { desc = 'Open Neotree' })
km.set("n", "<C-n>", ":Neotree filesystem reveal right<CR>", {})
km.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})

local configs = require("nvim-treesitter.configs")
configs.setup({
	ensure_installed = { "ruby", "python", "matlab", 
	"lua", "vim", "vimdoc", "elvish", "bash", "ini",
	"json", "yaml", "toml", "xml", "javascript", "html" },
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },  
})
