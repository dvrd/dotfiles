return {
	{
		"weilbith/nvim-code-action-menu",
		cmd = "CodeActionMenu",
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
		opts = {
			servers = {
				rust_analyzer = {
					checkOnSave = {
						command = "clippy",
					},
					cargo = {
						allFeatures = true,
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using
								-- (most likely LuaJIT in the case of Neovim)
								version = 'LuaJIT',
							},
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = {
									'vim',
									'require'
								},
							},
							workspace = {
								-- Make the server aware of Neovim runtime files
								library = vim.api.nvim_get_runtime_file("", true),
							},
							completion = {
								callSnippet = "Replace"
							},
							telemetry = { enable = false },
							hint = {
								enable = false,
							},
						},
					},
				},
			},
			setup = {},
			format = {
				timeout_ms = 3000,
			}
		},
		config = function(plugin, opts)
			vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
			vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

			local border = {
				{ "🭽", "FloatBorder" },
				{ "▔", "FloatBorder" },
				{ "🭾", "FloatBorder" },
				{ "▕", "FloatBorder" },
				{ "🭿", "FloatBorder" },
				{ "▁", "FloatBorder" },
				{ "🭼", "FloatBorder" },
				{ "▏", "FloatBorder" },
			}

			opts.handlers = {
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
			}

			require("plugins.lsp.servers").setup(plugin, opts)
		end,
	},
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = {
			ensure_installed = {
				"lua-language-server",
				"typescript-language-server",
				"rust-analyzer",
				"stylua",
				"shfmt",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
}
