function find_files()
	local opts = {}
	local telescope = require "telescope.builtin"
	local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")

	if git_dir ~= "" then
		local ok = pcall(telescope.git_files, opts)
		if not ok then
			telescope.find_files(opts)
		end
	else
		telescope.find_files(opts)
	end
end

return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.2',
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make"
		},
		"benfowler/telescope-luasnip.nvim",
		"olacin/telescope-cc.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"tsakirist/telescope-lazy.nvim",
		"aaronhallaert/advanced-git-search.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-lua/popup.nvim",
		"jvgrootveld/telescope-zoxide",
	},
	keys = {
		{
			"<leader><space>",
			"<cmd>Telescope<cr>",
			desc =
			"Find Files"
		},
		{
			"<leader>cd",
			"<cmd>Telescope zoxide list<cr>",
			desc = "Change Directory"
		},
		{
			"<leader>f",
			find_files,
			desc =
			"Find Files"
		},
		{
			"<leader>b",
			"<cmd>Telescope buffers<cr>",
			desc =
			"Buffers"
		},
		{
			"<leader>e",
			"<cmd>Telescope file_browser<cr>",
			desc =
			"Browser"
		},
		{
			"<leader>gc",
			"<cmd>Telescope conventional_commits<cr>",
			desc =
			"Commits"
		},
		{
			"<leader>zs",
			"<cmd>Telescope lazy<cr>",
			desc =
			"Search Plugins"
		},
		{
			"<leader>r",
			"<cmd>Telescope repo list<cr>",
			desc =
			"Repositories"
		},
		{
			"<leader>h",
			"<cmd>Telescope help_tags<cr>",
			desc =
			"Help Tags"
		},
		{
			"<leader>sw",
			"<cmd>Telescope live_grep<cr>",
			desc =
			"Search Workspace"
		},
		{
			"<leader>ss",
			"<cmd>Telescope luasnip<cr>",
			desc =
			"Look Snippets"
		},
		{
			"<leader>sb",
			function() require("telescope.builtin").current_buffer_fuzzy_find() end,
			desc =
			"Search Buffer",
		},
		{
			"<leader>zc",
			function() require("telescope.builtin").colorscheme({ enable_preview = true }) end,
			desc =
			"Select Colorscheme",
		},
	},
	opts = {
		pickers = {
			find_files = {
				theme = "dropdown",
				previewer = false,
				hidden = true,
				find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
			},
			git_files = {
				theme = "dropdown",
				previewer = false,
			},
			buffers = {
				theme = "dropdown",
				previewer = false,
			},
		},
	},
	config = function(_, opts)
		local telescope = require "telescope"
		local sorters = require "telescope.sorters"
		local z_utils = require "telescope._extensions.zoxide.utils"

		local icons = require "config.icons"
		local actions = require "telescope.actions"
		local actions_layout = require "telescope.actions.layout"

		local mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,
				["?"] = actions_layout.toggle_preview,
				["<ESC>"] = actions.close,
			},
		}

		opts.defaults = {
			prompt_prefix = icons.ui.Telescope .. " ",
			selection_caret = icons.ui.Forward .. " ",
			border = {},
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			color_devicons = true,
			mappings = mappings,
			file_sorter = sorters.get_fuzzy_file,
			generic_sorter = sorters.get_generic_fuzzy_sorter,
			vimgrep_arguments = {
				"rg",
				"-L",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
			},

		}

		opts.extensions = {
			file_browser = {
				theme = "dropdown",
				previewer = false,
				hijack_netrw = true,
				mappings = mappings,
			},
			project = {
				hidden_files = false,
				theme = "dropdown",
			},
		}

		opts.extensions = {
			zoxide = {
				prompt_title = "[ kakurega zoxide ]",
				mappings = {
					default = {
						after_action = function(selection)
							print("Update to (" .. selection.z_score .. ") " .. selection.path)
						end
					},
					["<C-s>"] = {
						before_action = function(selection) print("before C-s") end,
						action = function(selection)
							vim.cmd.edit(selection.path)
						end
					},
					-- Opens the selected entry in a new split
					["<C-q>"] = { action = z_utils.create_basic_command("split") },
				},
			}
		}


		telescope.setup(opts)
		telescope.load_extension "fzf"
		telescope.load_extension "file_browser"
		telescope.load_extension "luasnip"
		telescope.load_extension "conventional_commits"
		telescope.load_extension "lazy"
		telescope.load_extension "zoxide"
		telescope.load_extension "noice"
	end,
}
