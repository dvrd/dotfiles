local M = {}
local merge_tb = vim.tbl_deep_extend

-- local load_config = function()
-- 	local config = require "core.default_config"
-- 	local chadrc_path = vim.api.nvim_get_runtime_file("lua/custom/chadrc.lua", false)[1]

-- 	if chadrc_path then
-- 		local chadrc = dofile(chadrc_path)

-- 		config.mappings = M.remove_disabled_keys(chadrc.mappings, config.mappings)
-- 		config = merge_tb("force", config, chadrc)
-- 		config.mappings.disabled = nil
-- 	end

-- 	return config
-- end

local load_mappings = function(section, mapping_opt)
	vim.schedule(function()
		local function set_section_map(section_values)
			if section_values.plugin then
				return
			end

			section_values.plugin = nil

			for mode, mode_values in pairs(section_values) do
				local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
				for keybind, mapping_info in pairs(mode_values) do
					-- merge default + user opts
					local opts = merge_tb("force", default_opts, mapping_info.opts or {})

					mapping_info.opts, opts.mode = nil, nil
					opts.desc = mapping_info[2]

					vim.keymap.set(mode, keybind, mapping_info[1], opts)
				end
			end
		end

		local mappings = require("config.keymaps")

		if type(section) == "string" then
			mappings[section]["plugin"] = nil
			mappings = { mappings[section] }
		end

		for _, sect in pairs(mappings) do
			set_section_map(sect)
		end
	end)
end


return {
	{
		"NeogitOrg/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		config = true
	},
	{
		"lewis6991/gitsigns.nvim",
		ft = { "gitcommit", "diff" },
		init = function()
			-- load gitsigns only when a git file is opened
			vim.api.nvim_create_autocmd({ "BufRead" }, {
				group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
				callback = function()
					vim.fn.system("git -C " .. '"' .. vim.fn.expand "%:p:h" .. '"' .. " rev-parse")
					if vim.v.shell_error == 0 then
						vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
						vim.schedule(function()
							require("lazy").load { plugins = { "gitsigns.nvim" } }
						end)
					end
				end,
			})
		end,
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "󰍵" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "│" },
			},
			on_attach = function(bufnr)
				load_mappings("gitsigns", { buffer = bufnr })
			end,
		},
		config = function(_, opts)
			-- dofile(vim.g.base46_cache .. "git")
			require("gitsigns").setup(opts)
		end,
	},
}
