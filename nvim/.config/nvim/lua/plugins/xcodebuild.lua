return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "XcodebuildSetup",
      "XcodebuildPicker",
      "XcodebuildBuild",
      "XcodebuildBuildRun",
      "XcodebuildSelectDevice",
      "XcodebuildSelectScheme",
    },
    keys = {
      {
        "<leader>tx",
        "<cmd>XcodebuildPicker<cr>",
        desc = "Xcode selector",
      },
      {
        "<leader>txb",
        "<cmd>XcodebuildBuild<cr>",
        desc = "Xcode build",
      },
      {
        "<leader>txr",
        "<cmd>XcodebuildBuildRun<cr>",
        desc = "Xcode build and run",
      },
      {
        "<leader>txd",
        "<cmd>XcodebuildSelectDevice<cr>",
        desc = "Xcode select device",
      },
      {
        "<leader>txs",
        "<cmd>XcodebuildSelectScheme<cr>",
        desc = "Xcode select scheme",
      },
      {
        "<leader>txc",
        "<cmd>XcodebuildSetup<cr>",
        desc = "Xcode configure project",
      },
    },
    config = function()
      require("xcodebuild").setup({})
    end,
  },
}
