return {
	"rebelot/kanagawa.nvim",
	{
		"EdenEast/nightfox.nvim",
		priority = 100,
		lazy = false,
		config = function()
			vim.cmd("colorscheme carbonfox")
		end
	},
}
