--- Install lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
	spec = {
		{ import = "plugins" },
	},
	-- defaults = { lazy = true, version = nil },
	performance = {
		cache = {
			enabled = true,
		},
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
}

local keymap = vim.keymap.set

keymap("n", "<leader>zz", "<cmd>:Lazy<cr>", { desc = "Manage Plugins" })

keymap("n", "<leader>!", ":!", { desc = "Run bash" })
keymap("n", "<leader>=", ":=", { desc = "Run lua" })

-- Surround word with quotes
keymap("n", "<leader>a\"", "caw\"\"<esc>P", { desc = "Add quotes to word" })

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dp')

-- Auto indent
keymap("n", "i", function()
	if #vim.fn.getline "." == 0 then
		return [["_cc]]
	else
		return "i"
	end
end, { expr = true })

-- local save_and_exec = function()
-- 	if filetype == 'vim' then
-- 		vim.cmd("<cmd>silent! write")
-- 		vim.cmd("<cmd>source! %")
-- 	elseif filetype == 'lua' then
-- 		vim.cmd("<cmd>silent! write")
-- 		require("plenary.reload").reload_module('%')
-- 		vim.cmd("<cmd>luafile %")
-- 	end
-- end

-- keymap("n", "<leader>x :call <SID>save_and_exec()<CR>")
