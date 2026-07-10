return {
    "stevearc/conform.nvim",
    opts = {
        formatters = {
            prettier_odoo = {
                command = require("conform.util").from_node_modules("prettier"),
                args = { "--tab-width", "4", "--semi", "--no-single-quote", "--print-width", "100", "--stdin-filepath", "$FILENAME" },
                stdin = true,
            },
        },
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
