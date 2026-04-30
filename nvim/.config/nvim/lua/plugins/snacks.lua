local venv_excludes = { "**/.venv/**", "**/venv/**", "**/env/**" }

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><space>",
        function()
          Snacks.picker.git_files({ untracked = true })
        end,
        desc = "Find Files (git + hidden)",
      },
      {
        "<leader>e",
        function()
          local picker = Snacks.picker.get({ source = "explorer", tab = false })[1]
          if picker then
            if picker:is_focused() then
              vim.cmd("wincmd p")
            else
              picker:focus()
            end
          else
            Snacks.explorer({ cwd = LazyVim.root() })
          end
        end,
        desc = "Explorer Snacks (root dir)",
      },
    },
    opts = {
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = true,
          float = true,
        },
      },
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = venv_excludes,
          },
          explorer = {
            hidden = true,
            ignored = true,
            exclude = venv_excludes,
          },
        },
      },
    },
  },
}
