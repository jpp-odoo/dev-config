-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = true

-- Set to false to disable eslint auto format
-- vim.g.lazyvim_eslint_auto_format = false

-- LazyVim auto format
-- vim.g.autoformat = false

-- Always search in cwd, this remove the difference between Root Dir and cwd (they all search cwd now !)
vim.g.root_spec = { "cwd" }

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = false
--
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smarttab = true
