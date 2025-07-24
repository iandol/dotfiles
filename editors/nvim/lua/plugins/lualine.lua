return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('lualine').setup {
			options = {
				theme = 'material', 
				icons_enabled = true,
				section_separators = { left = '', right = '' },
				component_separators = { left = '', right = '' },
			}
		}
	end
}
