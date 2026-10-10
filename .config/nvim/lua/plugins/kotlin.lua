local default_editorconfig = vim.fn.stdpath("config") .. "/.editorconfig"

-- Prioritize the nearest Bazel package (BUILD.bazel / BUILD) or Gradle module (build.gradle*)
-- so kotlin-language-server scopes each module cleanly instead of merging entire monorepos.
local kotlin_root_markers = {
  {
    "BUILD.bazel",
    "BUILD",
    "build.gradle",
    "build.gradle.kts",
    "pom.xml",
    "build.xml",
  },
  {
    "settings.gradle",
    "settings.gradle.kts",
    ".bazelproject",
  },
}

return {
  -- Configure kotlin_language_server for Bazel/Gradle roots and Google 2-space style
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {
          root_markers = kotlin_root_markers,
          before_init = function(params, config)
            local root = config.root_dir or params.rootPath or "default"
            local root_hash = vim.fn.sha256(root):sub(1, 16)
            local cache_dir = vim.fn.expand("~/.cache/kotlin-language-server/db-" .. root_hash)
            vim.fn.mkdir(cache_dir, "p")
            config.init_options = config.init_options or {}
            config.init_options.storagePath = cache_dir
            params.initializationOptions = params.initializationOptions or {}
            params.initializationOptions.storagePath = cache_dir
          end,
          on_attach = function(client)
            -- Disable documentHighlight on kotlin_language_server due to a KLS bug
            -- (NoTopLevelDescriptorProvider.shouldNotBeCalled) when cursor is on class/interface headers.
            client.server_capabilities.documentHighlightProvider = false
          end,
          settings = {
            kotlin = {
              compiler = {
                jvm = {
                  target = "17",
                },
              },
              formatting = {
                formatter = "ktfmt",
                ktfmt = {
                  style = "google",
                },
              },
            },
          },
        },
      },
    },
  },

  -- Disable noisy ktlint diagnostics in nvim-lint (Google Kotlin style uses ktfmt, not ktlint)
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        kotlin = {},
      },
    },
  },

  -- Configure ktlint formatter in conform.nvim to use 2-space indent by default
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ktlint = {
          prepend_args = { "--editorconfig=" .. default_editorconfig },
        },
      },
    },
  },
}
