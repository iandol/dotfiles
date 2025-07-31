-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", 
		lazyrepo, lazypath })
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

-- general options
require('options')

-- Setup lazy.nvim
require("lazy").setup("plugins")

-- do not know why but plugin opts {} do not seem to work
require("neo-tree").setup({
	popup_border_style = "", -- "" to use 'winborder' on Neovim v0.11+
	window = {
		position = "right",
		width = 40,
	},})

-- enable lua lsp
vim.lsp.enable({'elvishls'})

-- keymaps
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set("n", "<leader>lk", vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {desc = "LSP Definition"})
vim.keymap.set("n", "<leader>lrf", vim.lsp.buf.references, {desc = "LSP References"})
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, {desc = "LSP Code Action"})
vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename, {desc = '[R]e[n]ame'})
