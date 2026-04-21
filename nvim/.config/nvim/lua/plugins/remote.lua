return {
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = true,
    keys = {
      { "<leader>Rc", "<cmd>RemoteStart<cr>", desc = "Connect to remote" },
      { "<leader>Rd", "<cmd>RemoteStop<cr>", desc = "Disconnect from remote" },
      { "<leader>Ri", "<cmd>RemoteInfo<cr>", desc = "Remote session info" },
      { "<leader>Rl", "<cmd>RemoteLog<cr>", desc = "Remote log" },
    },
  },
}
