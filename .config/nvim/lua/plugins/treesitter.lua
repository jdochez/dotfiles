return  {
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",
  config = function() 
    local config = require("nvim-treesitter.configs")
    config.setup( {
      ensure_installed = { "lua", "java", "kotlin", "bash", "html", "markdown", "proto", "vim", "vimdoc" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
 
