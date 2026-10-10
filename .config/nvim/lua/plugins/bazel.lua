-- Errorformat matching Bazel kotlinc, javac, and BUILD.bazel errors
local bazel_errorformat = table.concat({
  "%E%f:%l:%c: error: %m",
  "%W%f:%l:%c: warning: %m",
  "%E%f:%l: error: %m",
  "%W%f:%l: warning: %m",
  "%Ee: file://%f:%l:%c %m",
  "%Ww: file://%f:%l:%c %m",
  "%Ee: %f:%l:%c %m",
  "%Ww: %f:%l:%c %m",
  "%Ee: %f: (%l\\, %c): %m",
  "%Ww: %f: (%l\\, %c): %m",
  "%-GERROR: %.%#failed: (Exit %.%#",
  "%EERROR: %f:%l:%c: %m",
  "%EERROR: %f:%l: %m",
  "%-G%.%#",
}, ",")

-- Helper to locate the Bazel workspace root and current package label (e.g. //tools/vendor/google/lume/...)
local function get_bazel_context(project_wide)
  local buf_path = vim.api.nvim_buf_get_name(0)
  local start_dir = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":p:h") or vim.fn.getcwd()
  local root = vim.fs.root(start_dir, { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE" })
  if not root then
    return nil, nil
  end
  local target_dir
  if project_wide then
    target_dir = vim.fs.root(start_dir, { ".bazelproject" }) or start_dir
  else
    local build_file = vim.fs.find({ "BUILD.bazel", "BUILD" }, { upward = true, path = start_dir, stop = root })[1]
    target_dir = build_file and vim.fn.fnamemodify(build_file, ":h") or start_dir
  end
  local rel_pkg = target_dir:sub(#root + 2)
  local target = rel_pkg ~= "" and ("//" .. rel_pkg .. "/...") or "//..."
  return root, target
end

local function make_bazel_task_defn(subcmd, root, target)
  return {
    name = string.format("bazel %s %s", subcmd, target),
    cmd = { "bazel", subcmd, "--color=no", "--curses=no", target },
    cwd = root,
    strategy = { "jobstart", use_terminal = false },
    components = {
      {
        "on_output_quickfix",
        errorformat = bazel_errorformat,
        open_on_match = true,
        open_height = 8,
        close = true,
        items_only = true,
        set_diagnostics = true,
        tail = false,
      },
      "default",
    },
  }
end

local function run_bazel(subcmd, project_wide)
  local root, target = get_bazel_context(project_wide)
  if not root or not target then
    vim.notify("Not inside a Bazel workspace", vim.log.levels.WARN)
    return
  end
  local overseer = require("overseer")
  local task = overseer.new_task(make_bazel_task_defn(subcmd, root, target))
  task:start()
  vim.notify(string.format("Started: bazel %s %s", subcmd, target), vim.log.levels.INFO)
end

-- Allow single-clicking any error line in the Quickfix window to jump directly to the file/line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set("n", "<CR>", "<CR>", { buffer = event.buf, silent = true })
    vim.keymap.set("n", "<LeftRelease>", "<CR>", { buffer = event.buf, silent = true, desc = "Jump to error on click" })
  end,
})

return {
  -- Ensure Treesitter parses Starlark (Bazel's language)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "starlark", "python" })
      end
    end,
  },

  -- Starlark / BUILD LSP support via starpls
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        starpls = {},
      },
    },
  },

  -- Format BUILD / .bzl files with buildifier
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        bzl = { "buildifier" },
      },
    },
  },

  -- Overseer Bazel keymaps & templates
  {
    "stevearc/overseer.nvim",
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
      for _, item in ipairs({
        { subcmd = "build", project_wide = true, label = "bazel build project" },
        { subcmd = "build", project_wide = false, label = "bazel build package" },
        { subcmd = "test", project_wide = true, label = "bazel test project" },
        { subcmd = "test", project_wide = false, label = "bazel test package" },
      }) do
        overseer.register_template({
          name = item.label,
          builder = function()
            local root, target = get_bazel_context(item.project_wide)
            return make_bazel_task_defn(item.subcmd, root, target)
          end,
          condition = {
            callback = function()
              local root = get_bazel_context(item.project_wide)
              return root ~= nil
            end,
          },
        })
      end
    end,
    keys = {
      {
        "<leader>ob",
        function()
          run_bazel("build", true)
        end,
        desc = "Bazel build project (.bazelproject //...)",
      },
      {
        "<leader>ot",
        function()
          run_bazel("test", true)
        end,
        desc = "Bazel test project (.bazelproject //...)",
      },
      {
        "<leader>oB",
        function()
          run_bazel("build", false)
        end,
        desc = "Bazel build current package (BUILD //...)",
      },
      {
        "<leader>oT",
        function()
          run_bazel("test", false)
        end,
        desc = "Bazel test current package (BUILD //...)",
      },
    },
  },
}
