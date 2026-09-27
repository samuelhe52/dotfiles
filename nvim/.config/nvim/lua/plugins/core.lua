return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(highlights)
        -- rust-analyzer marks captured format-string identifiers as variables.
        -- TokyoNight intentionally leaves generic LSP variables unstyled so
        -- Treesitter can provide the color; inside a Rust string that means
        -- the identifier inherits @string instead.
        highlights["@lsp.type.variable.rust"] = { link = "@variable" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
