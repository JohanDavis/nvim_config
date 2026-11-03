-- Leader keys (must be set before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Core configuration
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.lsp")
