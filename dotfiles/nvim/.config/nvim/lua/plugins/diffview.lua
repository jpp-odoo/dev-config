return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },

    keys = {
      {
        "<leader>gv",
        function()
          if next(require("diffview.lib").views) == nil then
            require("utils").git_repo_or_pick(function(root)
              vim.cmd("DiffviewOpen -C=" .. vim.fn.fnameescape(root))
            end)
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview window",
      },
    },
  },
}
