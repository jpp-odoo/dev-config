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

--- Get the git toplevel for a file path.
---@param filepath string
---@return string
local function git_toplevel(filepath)
    local dir = vim.fn.fnamemodify(filepath, ":h")
    return vim.trim(vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }))
end

--- Convert a git remote URL to an HTTPS base URL.
---@param remote_url string
---@return string
local function remote_to_https(remote_url)
    return remote_url
        :gsub("git@([^:]+):(.+)%.git$", "https://%1/%2")
        :gsub("git@([^:]+):(.+)$", "https://%1/%2")
        :gsub("%.git$", "")
end

--- Deduce the base branch from a branch name.
--- Convention: <base>-<feature>[-<author>]
--- Handles saas- prefixed branches (e.g. saas-18.1-feature → saas-18.1).
---@param branch string
---@return string
local function base_branch(branch)
    return branch:match("^(saas%-[^%-]+)") or branch:match("^([^%-]+)") or branch
end

--- Parse fetch remotes from `git remote -v`.
---@param cwd string
---@return {name: string, url: string}[]
local function get_remotes(cwd)
    local lines = vim.fn.systemlist({ "git", "-C", cwd, "remote", "-v" })
    local remotes = {}
    local seen = {}
    for _, line in ipairs(lines) do
        local name, url = line:match("(%S+)%s+(%S+)%s+%(fetch%)")
        if name and not seen[name] then
            seen[name] = true
            table.insert(remotes, { name = name, url = url })
        end
    end
    return remotes
end

--- Prompt user to pick a remote (auto-selects if only one), then call cb.
---@param remotes {name: string, url: string}[]
---@param cb fun(remote: {name: string, url: string})
local function pick_remote(remotes, cb)
    if #remotes == 0 then
        vim.notify("No git remotes found", vim.log.levels.WARN)
        return
    end
    if #remotes == 1 then
        return cb(remotes[1])
    end
    vim.ui.select(remotes, {
        prompt = "Select remote:",
        format_item = function(r)
            return r.name .. "  " .. r.url
        end,
    }, function(choice)
        if choice then
            cb(choice)
        end
    end)
end

--- Open the blame commit for the current line in Diffview and show a GitHub link.
function M.git_blame_commit()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("No file", vim.log.levels.WARN)
        return
    end
    local line = vim.fn.line(".")
    local root = git_toplevel(file)
    local blame = vim.fn.system({ "git", "-C", root, "blame", "-l", "-L", line .. "," .. line, "--", file })
    local hash = blame:match("^(%x+)")
    if not hash or hash:match("^0+$") then
        vim.notify("Line not yet committed", vim.log.levels.WARN)
        return
    end

    require("diffview")
    vim.cmd("DiffviewOpen " .. hash .. "^! -C=" .. vim.fn.fnameescape(root))

    local remotes = get_remotes(root)
    local links = {}
    for _, r in ipairs(remotes) do
        local base = remote_to_https(r.url)
        table.insert(links, r.name .. ": " .. base .. "/commit/" .. hash)
    end
    if #links > 0 then
        Snacks.notify(table.concat(links, "\n"), { title = "Blame Commit", timeout = 0 })
    end
end

--- Copy a permalink for the current line (or visual selection) to the clipboard.
--- Uses git blame to find the commit hash and original line number so the URL
--- always points to the correct content, even when the local file has shifted
--- line numbers relative to the base branch.
function M.copy_git_permalink()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("No file", vim.log.levels.WARN)
        return
    end
    local root = git_toplevel(file)
    local rel = vim.trim(vim.fn.system({ "git", "-C", root, "ls-files", "--full-name", file }))
    if rel == "" then
        vim.notify("File not tracked by git", vim.log.levels.WARN)
        return
    end

    local line_start, line_end
    local mode = vim.fn.mode()
    if mode:find("[vV]") or mode == "\22" then
        line_start = vim.fn.line("v")
        line_end = vim.fn.line(".")
        if line_start > line_end then
            line_start, line_end = line_end, line_start
        end
    else
        line_start = vim.fn.line(".")
        line_end = line_start
    end

    -- Use git blame to get the original commit + line number for the first line.
    -- --porcelain output: "<hash> <orig_line> <final_line> <num_lines>"
    local blame = vim.fn.system({
        "git", "-C", root, "blame", "--porcelain",
        "-L", line_start .. "," .. line_start, "--", file,
    })
    local hash, orig_line = blame:match("^(%x+) (%d+)")
    orig_line = tonumber(orig_line)

    if not hash or hash:match("^0+$") or not orig_line then
        vim.notify("Line not yet committed", vim.log.levels.WARN)
        return
    end

    -- Offset the end line by the same delta so ranges stay consistent.
    local orig_start = orig_line
    local orig_end = orig_start + (line_end - line_start)

    local fragment
    if orig_start == orig_end then
        fragment = "#L" .. orig_start
    else
        fragment = "#L" .. orig_start .. "-L" .. orig_end
    end

    local remotes = get_remotes(root)
    pick_remote(remotes, function(remote)
        local repo_url = remote_to_https(remote.url)
        local url = repo_url .. "/blob/" .. hash .. "/" .. rel .. fragment
        vim.fn.setreg("+", url)
        vim.notify("Copied: " .. url)
    end)
end

return M
