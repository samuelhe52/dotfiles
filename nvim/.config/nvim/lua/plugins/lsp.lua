return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clang-format",
        "copilot-language-server",
        "google-java-format",
        "prettier",
        "shfmt",
        "stylua",
        "taplo",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { "clang-format" }
      opts.formatters_by_ft.cpp = { "clang-format" }
      opts.formatters_by_ft.swift = { "swift_format" }
      opts.formatters_by_ft.java = { "google-java-format" }
      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.python = { "ruff_format" }
      opts.formatters_by_ft.sh = { "shfmt" }
      opts.formatters_by_ft.bash = { "shfmt" }
      opts.formatters_by_ft.zsh = { "shfmt" }
      opts.formatters_by_ft.markdown = { "prettier" }
      opts.formatters_by_ft["markdown.mdx"] = { "prettier" }
      opts.formatters_by_ft.json = { "prettier" }
      opts.formatters_by_ft.jsonc = { "prettier" }
      opts.formatters_by_ft.yaml = { "prettier" }
      opts.formatters_by_ft.toml = { "taplo" }
      opts.formatters_by_ft.fish = nil
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        java_language_server = {
          enabled = false,
        },
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_markers = {
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac",
            "configure.in",
            "Makefile",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja",
            ".git",
          },
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        pyright = {
          before_init = function(_, config)
            local python_path = nil

            local has_venv_selector, venv_selector = pcall(require, "venv-selector")
            if has_venv_selector then
              python_path = venv_selector.python()
            end

            if not python_path then
              local python_env = require("config.python").resolve(config.root_dir or vim.fn.getcwd())
              python_path = python_env.python
            end

            if python_path then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python_path
            end
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
                autoImportCompletions = true,
              },
            },
          },
          handlers = {
            -- Keep pyright available for navigation/completion, but suppress its live diagnostics UI.
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
        sourcekit = {
          cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
          filetypes = { "swift" },
          root_markers = { "buildServer.json", ".bsp", ".git" },
        },
        taplo = {},
      },
      setup = {
        clangd = function(_, opts)
          opts.capabilities = opts.capabilities or {}
          opts.capabilities.offsetEncoding = { "utf-16" }
        end,
      },
    },
  },
}
