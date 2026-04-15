-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- vim.keymap.set({ "n", "v" }, "H", "^", { desc = "[P]Go to the beginning line" })
-- vim.keymap.set({ "n", "v" }, "L", "$", { desc = "[P]go to the end of the line" })
--
-- y p  => yank RELATIVE path into " and +
vim.keymap.set("o", "p", function()
    local name = vim.api.nvim_buf_get_name(0) -- empty if [No Name]
    if name == "" then
        vim.notify("No file name for this buffer", vim.log.levels.WARN)
        return "<Esc>"
    end
    local path = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".") -- relative to cwd
    vim.fn.setreg("+", path)
    vim.fn.setreg('"', path)
    vim.notify("Yanked: " .. path)
    return "<Esc>" -- exit operator-pending
end, { expr = true, desc = "Yank relative file path" })

-- y P  => yank ABSOLUTE path into " and +
vim.keymap.set("o", "P", function()
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" then
        vim.notify("No file name for this buffer", vim.log.levels.WARN)
        return "<Esc>"
    end
    local path = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
    vim.fn.setreg("+", path)
    vim.fn.setreg('"', path)
    vim.notify("Yanked: " .. path)
    return "<Esc>"
end, { expr = true, desc = "Yank absolute file path" })

vim.keymap.set({ "n", "x" }, "<leader>gY", function()
    require("utils").copy_git_permalink()
end, { desc = "Copy Git Permalink" })
