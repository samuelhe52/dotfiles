local function project_root()
  return vim.fs.root(0, { "Makefile", ".git" }) or vim.fn.getcwd()
end

local function open_makefile_targets()
  local overseer = require("overseer")
  local root = project_root()

  overseer.preload_task_cache({ dir = root }, function()
    vim.cmd("OverseerRun")
  end)
end

return {
  {
    "stevearc/overseer.nvim",
    lazy = false,
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerRun",
      "OverseerShell",
      "OverseerTaskAction",
    },
    opts = {
      dap = false,
      task_list = {
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
        },
      },
      form = {
        win_opts = {
          winblend = 0,
        },
      },
      task_win = {
        win_opts = {
          winblend = 0,
        },
      },
    },
    keys = {
      {
        "<leader>to",
        "<cmd>OverseerToggle!<cr>",
        desc = "Task list",
      },
      {
        "<leader>tm",
        open_makefile_targets,
        desc = "Makefile targets",
      },
      {
        "<leader>ta",
        "<cmd>OverseerTaskAction<cr>",
        desc = "Task action",
      },
    },
    config = function(_, opts)
      require("overseer").setup(opts)

      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        callback = function()
          local root = project_root()
          require("overseer").preload_task_cache({ dir = root })
        end,
      })
    end,
  },
}
