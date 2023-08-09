local M = {}

local lsp_utils = require "plugins.lsp.utils"
local icons = require "config.icons"

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

local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = border("FloatBorder"),
		winhighlight = "Normal:CmpPmenu,CursorLine:CursorLineNr,Search:PmenuSel",
	}),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = border("FloatBorder")
	}),
}


local function lsp_init()
	local signs = {
		{ name = "DiagnosticSignError", text = icons.diagnostics.Error },
		{ name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
		{ name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
		{ name = "DiagnosticSignInfo",  text = icons.diagnostics.Info },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
	end

	local config = {
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
		},
		diagnostic = {
			virtual_text = {
				severity = {
					min = vim.diagnostic.severity.ERROR,
				},
			},
			signs = {
				active = signs,
			},
			underline = false,
			update_in_insert = false,
			severity_sort = true,
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		},
	}

	vim.diagnostic.config(config.diagnostic)
end

function M.setup(_, opts)
	lsp_utils.on_attach(function(client, bufnr)
		require("plugins.lsp.format").on_attach(client, bufnr)
		require("plugins.lsp.keymaps").on_attach(client, bufnr)
	end)

	lsp_init()

	local servers = opts.servers
	local capabilities = lsp_utils.capabilities()

	local function setup(server)
		local server_opts = vim.tbl_deep_extend("force", {
			capabilities = capabilities,
			handlers = handlers,
		}, servers[server] or {})

		if opts.setup[server] then
			if opts.setup[server](server, server_opts) then
				return
			end
		elseif opts.setup["*"] then
			if opts.setup["*"](server, server_opts) then
				return
			end
		end
		require("lspconfig")[server].setup(server_opts)
	end

	local have_mason, mlsp = pcall(require, "mason-lspconfig")
	local all_mslp_servers = {}
	if have_mason then
		all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
	end

	local ensure_installed = {} ---@type string[]
	for server, server_opts in pairs(servers) do
		if server_opts then
			server_opts = server_opts == true and {} or server_opts
			if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
				setup(server)
			else
				ensure_installed[#ensure_installed + 1] = server
			end
		end
	end

	if have_mason then
		mlsp.setup { ensure_installed = ensure_installed }
		mlsp.setup_handlers { setup }
	end
end

return M
