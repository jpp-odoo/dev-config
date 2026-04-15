return {
    "neovim/nvim-lspconfig",
    opts = {
        inlay_hints = { enabled = false },
        servers = {
            eslint = {},
            pyright = {
                settings = {
                    pyright = {
                        disableOrganizeImports = true, -- Using Ruff
                    },
                    python = {
                        analysis = {
                            ignore = { "*" }, -- Using Ruff
                        },
                    },
                },
            },
            ruff = {
                init_options = {
                    settings = {
                        lint = {
                            select = { "All" },
                            preview = true,
                            ignore = {
                                "ANN",
                                "B",
                                "C901",
                                "COM812",
                                "D",
                                "E501",
                                "E741",
                                "EM101",
                                "ERA001",
                                "FBT",
                                "I001",
                                "N",
                                "PD",
                                "PERF",
                                "PIE790",
                                "PLR",
                                "PT",
                                "Q",
                                "RET502",
                                "RET503",
                                "RSE102",
                                "RUF001",
                                "RUF012",
                                "S",
                                "SIM102",
                                "SIM108",
                                "SLF001",
                                "TID252",
                                "UP031",
                                "TRY002",
                                "TRY003",
                                "TRY300",
                                "UP038",
                                "E713",
                                "SIM117",
                                "PGH003",
                                "RUF005",
                                "RET",
                                "DTZ",
                                "FIX",
                                "TD",
                                "ARG",
                                "TRY400",
                                "TRY200",
                                "C408",
                                "PLW2901",
                                "PTH",
                                "EM102",
                                "INP001",
                                "CPY001",
                                "UP006",
                                "UP007",
                                "E266",
                                "PIE811",
                            },
                        },
                        format = {
                            preview = true,
                        },
                    },
                },
            },
        },
        setup = {
            eslint = function()
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(args)
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if not client then return end
                        -- Enable formatting for eslint
                        if client.name == "eslint" then
                            client.server_capabilities.documentFormattingProvider = true
                            -- Disable formatting for ts_ls (formerly tsserver) / vtsls to avoid conflicts
                        elseif client.name == "tsserver" or client.name == "vtsls" or client.name == "ts_ls" then
                            client.server_capabilities.documentFormattingProvider = false
                        end
                    end,
                })
            end,
        },
    },
}
