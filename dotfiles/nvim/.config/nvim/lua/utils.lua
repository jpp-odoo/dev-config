local M = {}

-- Always prompts the user to pick a git repository from cwd.
-- Discovers all repos one level deep. Auto-selects silently if only one found.
-- cb(root_path) is called with the selected path.
function M.git_repo_or_pick(cb)
    local cwd = vim.fn.getcwd()
    local git_dirs = vim.fn.glob(cwd .. "/*/.git", false, true)
    local repos = vim.tbl_map(function(d)
        return vim.fn.fnamemodify(d, ":h")
    end, git_dirs)

    if #repos == 0 then
        vim.notify("No git repositories found in " .. cwd, vim.log.levels.WARN)
        return
    elseif #repos == 1 then
        cb(repos[1])
        return
    end

    vim.ui.select(repos, {
        prompt = "Select repository:",
        format_item = function(p)
            return vim.fn.fnamemodify(p, ":t")
        end,
    }, function(choice)
        if choice then cb(choice) end
    end)
end

return M
