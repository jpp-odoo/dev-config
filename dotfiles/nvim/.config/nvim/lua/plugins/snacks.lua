return {
    "folke/snacks.nvim",
    keys = {
        {
            -- Override LazyVim default: opens lazygit for the buffer's repo,
            -- or prompts to pick a repo when no buffer is open
            "<leader>gg",
            function()
                require("utils").git_repo_or_pick(function(root)
                    Snacks.lazygit({ cwd = root })
                end)
            end,
            desc = "Lazygit (buffer repo)",
        },
    },
    opts = {
        -- explorer = { enabled = false, auto_close = true },
        -- dashboard = {
        --   sections = {
        --     { section = "header" },
        --     { section = "keys", gap = 1, padding = 1 },
        --     -- { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 2, 2 } },
        --     -- { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        --     { section = "startup" },
        --     {
        --       section = "terminal",
        --       cmd = "ascii-image-converter ~/.config/logo_wo_bg.png -C -b --threshold 1",
        --       random = 10,
        --       pane = 2,
        --       indent = 4,
        --       height = 30,
        --     },
        --   },
        -- },
        picker = {
            auto_close = true,
            matcher = {
                frecency = true,
                history_bonus = true,
            },
            formatters = {
                file = {
                    truncate = 80,
                },
            },
            win = {
                input = {
                    keys = {
                        -- Close picker
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
            },
        },
        styles = {
            notification = {
                wo = { wrap = true },
            },
        },
    },
}
