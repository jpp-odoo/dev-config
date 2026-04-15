-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- autosave
-- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--     pattern = { "*" },
--     command = "silent! wall",
--     nested = true,
-- })

-- Disable autoformat for javascript ad python files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "javascript", "python" },
    callback = function()
        vim.b.autoformat = false
    end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    pattern = { "*" },
    callback = function()
        -- Skip Claude diff buffers so proposed changes aren't auto-saved before review
        local name = vim.api.nvim_buf_get_name(0)
        if name:match("%(proposed%)") or name:match("%(NEW FILE") then
            return
        end
        vim.cmd("silent! wall")
    end,
    nested = true,
})
