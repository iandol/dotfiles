return {
	'nvim-telescope/telescope.nvim', tag = '0.1.8',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('telescope').setup {
			defaults = { scroll_strategy = "cycle", },
			pickers = { find_files = { follow = true } }
		}
		local tsbuiltin = require('telescope.builtin')
		local km = vim.keymap
		km.set('n', '<leader>ff', tsbuiltin.find_files, { desc = 'Telescope find files' })
		km.set('n', '<leader>fg', tsbuiltin.live_grep, { desc = 'Telescope live grep' })
		km.set('n', '<leader>fb', tsbuiltin.buffers, { desc = 'Telescope buffers' })
		km.set('n', '<leader>fh', tsbuiltin.help_tags, { desc = 'Telescope help tags' })
	end
}

