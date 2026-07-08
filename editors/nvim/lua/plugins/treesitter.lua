return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"neovim-treesitter/nvim-treesitter-queries-elvish",
	},
	config = function()
		require('nvim-treesitter').install { "ruby", "python", "matlab",
				"lua", "vim", "vimdoc", "elvish", "bash", "ini",
				"json", "yaml", "toml", "xml", "javascript", "html" }
	end
}
