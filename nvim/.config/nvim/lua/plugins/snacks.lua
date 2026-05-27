local picker_excludes = {
  "**/.venv/**",
  "**/venv/**",
  "**/env/**",
  "**/.DS_Store",
  "**/._*",
  "**/Thumbs.db",
}

local function is_git_repo(cwd)
  local result = vim.fn.system({
    "git",
    "-C",
    cwd,
    "rev-parse",
    "--is-inside-work-tree",
  })

  return vim.v.shell_error == 0 and vim.trim(result) == "true"
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><space>",
        function()
          local cwd = LazyVim.root()
          if is_git_repo(cwd) then
            Snacks.picker.git_files({ cwd = cwd, untracked = true })
          else
            Snacks.picker.files({ cwd = cwd })
          end
        end,
        desc = "Find Files (git or all)",
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
            exclude = picker_excludes,
          },
          explorer = {
            hidden = true,
            ignored = true,
            exclude = picker_excludes,
          },
        },
      },
    },
  },
}
