return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          project = {
            sourcePaths = { "src" },
            outputPath = "out",
          },
        },
      })

      opts.root_dir = function(path)
        local root = vim.fs.root(path, {
          ".git",
          "mvnw",
          "gradlew",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
          ".project",
          ".classpath",
        })

        if root then
          return root
        end

        local src_dir = vim.fs.find("src", {
          path = vim.fs.dirname(path),
          upward = true,
          type = "directory",
        })[1]

        if src_dir then
          return vim.fs.dirname(src_dir)
        end

        return vim.fs.dirname(path)
      end

      return opts
    end,
  },
}
