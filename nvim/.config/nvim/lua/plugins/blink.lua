return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap.preset = "super-tab"

      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.snippets = opts.sources.providers.snippets or {}
      opts.sources.providers.snippets.opts = opts.sources.providers.snippets.opts or {}

      -- Hide the friendly-snippets global file entirely so its generic helpers
      -- (like `copyright`) do not appear in completion.
      opts.sources.providers.snippets.opts.filter_snippets = function(_, file)
        return not file:find("friendly-snippets/snippets/global.json", 1, true)
      end
    end,
  },
}
