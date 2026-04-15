return {
    "mfussenegger/nvim-dap-python",
    config = function()
        local dap_python = require("dap-python")
        local adapter_python_path = require("mason-registry").get_package("debugpy"):get_install_path()
            .. "/venv/bin/python"
        dap_python.setup(adapter_python_path)
        -- TODO: I think the next line is not needed for Odoo, we lunch the tests in odoo itself !
        -- require("dap-python").test_runner = "pytest"
        -- TODO: if this works, I need to create a second one for the port 5679 (local.dev1)
        table.insert(require("dap").configurations.python, {
            type = "python",
            request = "attach",
            connect = {
                port = 5678,
                host = "127.0.0.1",
            },
            mode = "remote",
            name = "Debug Odoo",
            cwd = vim.fn.getcwd(),
            pathMappings = {
                {
                    localRoot = function()
                        -- TODO remove the inputs, they are not needed, the default folder is correct.
                        return vim.fn.input("Local code folder > ", vim.fn.getcwd(), "file")
                        --"~/src/odoo-src/master/", -- Local folder the code lives
                    end,
                    remoteRoot = function()
                        local parts = vim.split(vim.fn.getcwd(), "[\\/]")
                        return vim.fn.input("Container code folder > ", "/src/" .. parts[#parts] .. "/", "file")
                        -- "/src/master", -- Wherever your Python code lives in the container.
                    end,
                },
            },
        })
    end,
}
