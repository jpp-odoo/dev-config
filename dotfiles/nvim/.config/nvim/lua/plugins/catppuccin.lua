return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { light = "latte", dark = "mocha" },
        transparent_background = false,
        highlight_overrides = {
            all = function(colors)
                return {
                    -- Supermaven ghost text: muted, italic to distinguish from real code
                    SupermavenSuggestion = { fg = colors.overlay1, italic = true },
                }
            end,
        },
        integrations = {
            blink_cmp = true,
            diffview = true,
            flash = true,
            gitsigns = true,
            illuminate = { enabled = true },
            lsp_trouble = true,
            mason = true,
            mini = { enabled = true },
            navic = { enabled = true },
            noice = true,
            notify = true,
            snacks = true,
            treesitter = true,
            treesitter_context = true,
            which_key = true,
        },
    },
}
