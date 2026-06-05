return {
	"nvim-treesitter/nvim-treesitter",
	lazy = "false",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = { "ruby", "python", "matlab",
				"lua", "vim", "vimdoc", "elvish", "bash", "ini",
				"json", "yaml", "toml", "xml", "javascript", "html" },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end
}
