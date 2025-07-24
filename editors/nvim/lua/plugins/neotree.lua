return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		--"folke/snacks.nvim",
	},
	opts = {
		window = { position = "right", },
	},
	config = function()
		vim.keymap.set("n", "<leader>e", ":Neotree filesystem toggle right<CR>", { desc = 'files in Neotree' })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers toggle float<CR>", { desc = 'buffers in Neotree' })
	end,
}
