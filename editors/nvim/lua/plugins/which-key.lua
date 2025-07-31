return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = { 
		delay = 0, 
		---@type false | "classic" | "modern" | "helix"
		preset = "modern",
		notify = true,
	},
	keys = {{"<leader>?", function() require("which-key").show({ global = true }) end, desc = "Buffer Local Keymaps (which-key)"}},
}
