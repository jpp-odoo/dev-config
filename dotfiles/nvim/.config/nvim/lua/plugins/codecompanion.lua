-- CodeCompanion: AI chat and refactoring via Gemini
-- Requires: set -gx GEMINI_API_KEY "your-key" in ~/.config/fish/config.fish
-- Get a key at: aistudio.google.com/apikey
--
-- Keys (<leader>G prefix to avoid conflicts with claudecode.nvim):
--   <leader>Ga  → action menu (explain, refactor, fix, generate tests...)
--   <leader>Gc  → toggle chat sidebar
--   <leader>Gi  → inline AI prompt

return {
    "olimorris/codecompanion.nvim",
    opts = {
        adapters = {
            gemini = function()
                return require("codecompanion.adapters").extend("gemini", {
                    env = { api_key = "GEMINI_API_KEY" },
                    schema = {
                        -- Verify the exact model ID at aistudio.google.com/models
                        model = { default = "gemini-2.5-pro" },
                    },
                })
            end,
        },
        strategies = {
            chat   = { adapter = "gemini" },
            inline = { adapter = "gemini" },
            agent  = { adapter = "gemini" },
        },
    },
    keys = {
        { "<leader>Ga", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI actions (Gemini)" },
        { "<leader>Gc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat (Gemini)" },
        { "<leader>Gi", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "AI inline (Gemini)" },
    },
}
