return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "jsonc", "rust", "swift" })
      end
      -- Swift Treesitter indent miscalculates trailing-closure blocks in SwiftUI.
      opts.indent = opts.indent or {}
      opts.indent.disable = opts.indent.disable or {}
      if not vim.tbl_contains(opts.indent.disable, "swift") then
        table.insert(opts.indent.disable, "swift")
      end
    end,
  },
}
