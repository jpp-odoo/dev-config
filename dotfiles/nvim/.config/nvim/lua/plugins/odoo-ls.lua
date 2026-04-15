-- Official Odoo Language Server (https://github.com/odoo/odoo-ls)
--
-- INSTALLATION (one-time):
--   1. Download odoo_ls_server from https://github.com/odoo/odoo-ls/releases
--      Pick the linux-x86_64 binary.
--   2. mv ~/Downloads/odoo_ls_server ~/.local/bin/
--      chmod +x ~/.local/bin/odoo_ls_server
--
-- PER-PROJECT SETUP: create odools.toml in each project root:
--   name = "my-project"
--   odoo_path = "/home/jpp/projects/my-env/odoo"
--   addons_paths = ["/home/jpp/projects/my-env/enterprise"]
--   python_path = "/home/jpp/projects/my-env/.venv/bin/python"
--
-- The server activates only when odools.toml is found — each repo manages
-- its own config, so multi-repo workspaces work without any extra setup.

return {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
        local ok_configs, configs = pcall(require, "lspconfig.configs")
        local ok_lsp, lspconfig = pcall(require, "lspconfig")
        if not ok_configs or not ok_lsp then
            return opts
        end

        if not configs.odoo_ls then
            configs.odoo_ls = {
                default_config = {
                    name = "odoo_ls",
                    cmd = { vim.fn.expand("~/.local/bin/odoo_ls_server") },
                    filetypes = { "python", "xml" },
                    root_dir = lspconfig.util.root_pattern("odools.toml"),
                    single_file_support = false,
                },
            }
        end

        opts.servers = opts.servers or {}
        opts.servers.odoo_ls = {}
        return opts
    end,
}
