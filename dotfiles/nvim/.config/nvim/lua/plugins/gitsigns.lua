return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    opts.current_line_blame = true
    opts.current_line_blame_opts = { delay = 300 }
    opts.current_line_blame_formatter = " <author>, <author_time:%R> · <summary>"

    local orig_on_attach = opts.on_attach
    opts.on_attach = function(bufnr)
      if orig_on_attach then
        orig_on_attach(bufnr)
      end
      -- Override LazyVim's <leader>ghb (gitsigns popup) with full Diffview commit
      vim.keymap.set("n", "<leader>ghb", function()
        require("utils").git_blame_commit()
      end, { buffer = bufnr, desc = "Blame Commit (Diffview + GitHub link)" })
    end
  end,
}
