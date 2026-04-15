return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
        terminal = {
            split_side = "right",
            split_width_percentage = 0.35,
            provider = "snacks",
            auto_close = true,
        },
    },
    keys = {
        { "<leader>ac", "<cmd>ClaudeCode<cr>",              desc = "Toggle Claude" },
        { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",         desc = "Focus Claude" },
        { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",     desc = "Resume Claude session" },
        { "<leader>aC", "<cmd>ClaudeCode --continue<cr>",   desc = "Continue Claude task" },
        { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>",   desc = "Select Claude model" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",         desc = "Add buffer to Claude" },
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
        { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",    desc = "Accept Claude diff" },
        { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",      desc = "Reject Claude diff" },
    },
}
