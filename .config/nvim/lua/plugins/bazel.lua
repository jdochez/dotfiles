return {
  -- 1. Official Bazel plugin for commands and filetype hooks
  {
    "bazelbuild/vim-bazel",
    ft = { "bzl", "bazel" },
    -- This plugin gives you :Bazel build, :Bazel test, etc.
  },

  -- 2. Ensure Treesitter parses Starlark (Bazel's language)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "starlark", "python" })
      end
    end,
  },
}
