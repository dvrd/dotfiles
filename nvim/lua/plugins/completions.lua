local cmp = {
	icons = true,
	lspkind_text = true,
	style = "default",           -- default/flat_light/flat_dark/atom/atom_colored
	border_color = "grey_fg",    -- only applicable for "default" style, use color names from base30 variables
	selected_item_bg = "colored", -- colored / simple
}

local field_arrangement = {
	atom = { "kind", "abbr", "menu" },
	atom_colored = { "kind", "abbr", "menu" },
}

local formatting_style = {
	-- default fields order i.e completion word + item.kind + item.kind icons
	fields = field_arrangement[cmp.style] or { "abbr", "kind", "menu" },

	format = function(_, item)
		local icons = require("config.icons").kind
		local icon = (cmp.icons and icons[item.kind]) or ""

		icon = cmp.lspkind_text and (" " .. icon .. " ") or icon
		item.kind = string.format("%s %s", icon, cmp.lspkind_text and item.kind or "")

		return item
	end,
}

local function border(hl_name)
	return {
		{ "╭", hl_name },
		{ "─", hl_name },
		{ "╮", hl_name },
		{ "│", hl_name },
		{ "╯", hl_name },
		{ "─", hl_name },
		{ "╰", hl_name },
		{ "│", hl_name },
	}
end

return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"petertriho/cmp-git",
			{
				"windwp/nvim-autopairs",
				opts = {
					fast_wrap = {},
					disable_filetype = { "TelescopePrompt", "vim" },
				},
				config = function(_, opts)
					require("nvim-autopairs").setup(opts)

					-- setup cmp for autopairs
					local cmp_autopairs = require "nvim-autopairs.completion.cmp"
					require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},
		},
		opts = function()
			local cmp = require "cmp"
			local luasnip = require "luasnip"
			-- local icons = require "config.icons"
			local compare = require "cmp.config.compare"
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
			end

			return {
				completion = {
					completeopt = "menu,menuone,noselect",
				},
				sorting = {
					priority_weight = 2,
					comparators = {
						compare.score,
						compare.recently_used,
						compare.offset,
						compare.exact,
						compare.kind,
						compare.sort_text,
						compare.length,
						compare.order,
					},
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert {
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
					["<C-j>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, {
						"i",
						"s",
						"c",
					}),
					["<C-k>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, {
						"i",
						"s",
						"c",
					}),

				},
				sources = cmp.config.sources {
					{ name = "nvim_lsp", group_index = 1 },
					{ name = "luasnip",  group_index = 1 },
					{ name = "buffer",   group_index = 2 },
					{ name = "path",     group_index = 2 },
					{ name = "git",      group_index = 2 },
					{ name = "orgmode",  group_index = 2 },
					{ name = "crates",   group_index = 2 },
				},
				formatting = formatting_style,
				window = {
					completion = {
						side_padding = (cmp.style ~= "atom" and cmp.style ~= "atom_colored") and 1 or 0,
						border = border("CmpDocBorder"),
						winhighlight = "Normal:CmpPmenu,CursorLine:CursorLineNr,Search:PmenuSel",
						scrollbar = false,
					},
					documentation = {
						border = border("CmpDocBorder"),
						winhighlight = "Normal:CmpPmenu,CursorLine:CursorLineNr,Search:PmenuSel",
					},
				},
			}
		end,
		config = function(_, opts)
			local cmp = require("cmp")

			cmp.setup(opts)

			cmp.setup.cmdline(':', {
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				})
			})

			-- Git
			require("cmp_git").setup { filetypes = { "NeogitCommitMessage" } }
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
			{
				"honza/vim-snippets",
				config = function()
					require("luasnip.loaders.from_snipmate").lazy_load()

					-- One peculiarity of honza/vim-snippets is that the file with the global snippets is _.snippets, so global snippets
					-- are stored in `ls.snippets._`.
					-- We need to tell luasnip that "_" contains global snippets:
					require("luasnip").filetype_extend("all", { "_" })
				end,
			},
		},
		build = "make install_jsregexp",
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		keys = {
			{
				"<C-j>",
				function()
					return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<C-j>"
				end,
				expr = true,
				remap = true,
				silent = true,
				mode = "i",
			},
			{ "<C-j>", function() require("luasnip").jump(1) end,  mode = "s" },
			{ "<C-k>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
		},
		config = function(_, opts)
			require("luasnip").setup(opts)

			local snippets_folder = vim.fn.stdpath "config" .. "/lua/plugins/completion/snippets/"
			require("luasnip.loaders.from_lua").lazy_load { paths = snippets_folder }

			vim.api.nvim_create_user_command("LuaSnipEdit", function()
				require("luasnip.loaders.from_lua").edit_snippet_files()
			end, {})
		end,
	},
}
