return {
	"nvim-treesitter/nvim-treesitter", 
	build = ":TSUpdate",
	config = function()
		require('nvim-treesitter.configs').setup {
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn", -- set to `false` to disable one of the mappings
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},
			highlight = {
				enable = true,
			},
			indent = {
				enable = true
			}
		}
	end,
}
