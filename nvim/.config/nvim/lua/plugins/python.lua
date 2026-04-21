return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    ft = "python",
    cmd = { "VenvSelect", "VenvSelectCached", "VenvSelectLog" },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select Python Venv" },
    },
    opts = {
      options = {
        notify_user_on_venv_activation = false,
        cached_venv_automatic_activation = true,
        activate_venv_in_terminal = true,
        require_lsp_activation = true,
        picker = "auto",
      },
    },
  },
}
