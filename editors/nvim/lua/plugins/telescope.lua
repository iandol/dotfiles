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
		km.set('n', '<leader>fh', tsbuiltin.help_tags, { desc = '[S]earch [H]elp' })
		km.set('n', '<leader>fk', tsbuiltin.keymaps, { desc = '[S]earch [K]eymaps' })
		km.set('n', '<leader>ff', tsbuiltin.find_files, { desc = '[S]earch [F]iles' })
		km.set('n', '<leader>fs', tsbuiltin.builtin, { desc = '[S]earch [S]elect Telescope' })
		km.set('n', '<leader>fw', tsbuiltin.grep_string, { desc = '[S]earch current [W]ord' })
		km.set('n', '<leader>fg', tsbuiltin.live_grep, { desc = '[S]earch by [G]rep' })
		km.set('n', '<leader>fd', tsbuiltin.diagnostics, { desc = '[S]earch [D]iagnostics' })
		km.set('n', '<leader>fr', tsbuiltin.resume, { desc = '[S]earch [R]esume' })
		km.set('n', '<leader>f.', tsbuiltin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		km.set('n', '<leader><leader>', tsbuiltin.buffers, { desc = '[ ] Find existing buffers' })
	end
}

