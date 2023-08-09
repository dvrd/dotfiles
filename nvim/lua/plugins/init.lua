return {
	"danro/rename.vim",
	"tpope/vim-commentary",
	"cfdrake/vim-pbxproj",
	"nvim-lua/plenary.nvim",
	"nvim-lua/popup.nvim",
	"folke/neodev.nvim",
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod",
		},
		config = function()
			vim.g.db_ui_env_variable_url = 'DATABASE_URL'
			vim.g.db_ui_env_variable_name = 'DATABASE_NAME'
		end
	},
	{ "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
	{
		"saecki/crates.nvim",
		tag = "v0.3.0",
		event = {
			"BufRead Cargo.toml"
		},
		dependencies = {
			"nvim-lua/plenary.nvim"
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			views = {
				cmdline_popup = {
					position = {
						row = 5,
						col = "50%",
					},
					size = {
						width = 60,
						height = "auto",
					},
				},
				popupmenu = {
					enabled = true,
					backend = "nui",
					relative = "editor",
					position = {
						row = 8,
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true,     -- use a classic bottom cmdline for search
				command_palette = true,   -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false,       -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true,    -- add a border to hover docs and signature help
			},
		},
	},
}
