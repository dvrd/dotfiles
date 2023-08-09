local show_image = function(opts)
	vim.cmd("!qlmanage -p " .. opts.fargs[1])
end

function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "' .. directory .. '"')
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end

vim.api.nvim_create_user_command("ViewImage", show_image, {
	nargs = 1,
	complete = function(ArgLead)
		local cwd = vim.fn.getcwd()
		return scandir(cwd)
	end,
})

local function augroup(name)
	return vim.api.nvim_create_augroup("drvd_" .. name, { clear = true })
end

-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = augroup "highlight_yank",
	pattern = "*",
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup "auto_create_dir",
	callback = function(event)
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup "checktime",
	command = "checktime",
})

-- Auto toggle hlsearch
local ns = vim.api.nvim_create_namespace "toggle_hlsearch"
local function toggle_hlsearch(char)
	if vim.fn.mode() == "n" then
		local keys = { "<CR>", "n", "N", "*", "#", "?", "/" }
		local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))

		if vim.opt.hlsearch:get() ~= new_hlsearch then
			vim.opt.hlsearch = new_hlsearch
		end
	end
end
vim.on_key(toggle_hlsearch, ns)

-- windows to close
vim.api.nvim_create_autocmd("FileType", {
	group = augroup "close_with_q",
	pattern = {
		"OverseerForm",
		"OverseerList",
		"checkhealth",
		"floggraph",
		"fugitive",
		"git",
		"help",
		"lspinfo",
		"man",
		"neotest-output",
		"neotest-summary",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"toggleterm",
		"tsplayground",
		"vim",
		"neoai-input",
		"neoai-output",
		"notify",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

vim.api.nvim_set_hl(0, "TerminalCursorShape", { underline = true })
vim.api.nvim_create_autocmd("TermEnter", {
	callback = function()
		vim.cmd [[setlocal winhighlight=TermCursor:TerminalCursorShape]]
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		vim.cmd [[set guicursor=a:ver25]]
	end,
})

-- -- show line diagnostics
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		if require("plugins.lsp.utils").show_diagnostics() then
			vim.schedule(vim.diagnostic.open_float)
		end
	end,
})
