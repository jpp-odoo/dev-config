return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            javascript = { "eslint_d" },
            python = {
                -- To fix auto-fixable lint errors.
                "ruff_fix",
                -- To run the Ruff formatter.
                "ruff_format",
                -- To organize the imports.
                "ruff_organize_imports",
            },
            gitcommit = { "commitmsgfmt" },
        },
    },
}
