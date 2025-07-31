return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		--"folke/snacks.nvim",
	},
	lazy = false, -- neo-tree will lazily load itself
	---@module 'neo-tree'
	---@type neotree.Config
	opts = {
		popup_border_style = "", -- "" to use 'winborder' on Neovim v0.11+
		window = {
			position = "right",
			width = 40,
		},
	},
	config = function()
		vim.keymap.set("n", "<leader>e", ":Neotree filesystem toggle right<CR>", { desc = 'files in Neotree' })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers toggle float<CR>", { desc = 'buffers in Neotree' })
	end,
}
