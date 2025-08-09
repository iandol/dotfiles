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
require("options")

-- Setup lazy.nvim
require("lazy").setup({
	spec = { import = "plugins" },
	git  = { timeout = 30 },
	install = { missing = false },
	ui = { size = { width = 0.8, height = 0.8 }, border = "", },
})

-- do not know why but plugin opts {} do not seem to work
require("neo-tree").setup({
	popup_border_style = "", -- "" to use 'winborder' on Neovim v0.11+
	source_selector = {
		winbar = true, -- toggle to show selector on winbar
	},
	window = {
		position = "right",
		width = 40,
	},
})

-- enable lua lsp
vim.lsp.enable({ 'elvishls' })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			}
		}
	}
})

-- keymaps
local km = vim.keymap
km.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload File" })
km.set("n", "<leader>w", ":write<CR>", { desc = "Write File" })
km.set("n", "<leader>q", ":write<CR> :quit<CR>", { desc = "Write & Quit" })
km.set("n", "<leader>s", ":SudaWrite<CR>", { desc = "Sudo Write File" })
km.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
km.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP Format" })
km.set("n", "<leader>lk", vim.lsp.buf.hover, { desc = "LSP Hover" })
km.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP Definition" })
km.set("n", "<leader>lrf", vim.lsp.buf.references, { desc = "LSP References" })
km.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
km.set("n", "<leader>lrn", vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
