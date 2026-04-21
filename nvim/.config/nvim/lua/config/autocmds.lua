vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"markdown",
		"json",
		"jsonc",
		"yaml",
		"toml",
		"sh",
		"bash",
		"zsh",
		"gitconfig",
		"gitcommit",
		"gitrebase",
	},
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover Documentation" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "objc", "objcpp", "java", "python", "swift" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "make" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.shiftwidth = 8
		vim.opt_local.tabstop = 8
		vim.opt_local.softtabstop = 0
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "txt", "plaintex", "gitcommit" },
	callback = function()
		vim.opt_local.spell = false
	end,
})
