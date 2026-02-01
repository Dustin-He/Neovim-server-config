-- 1. 加载基础配置
require("config.options")
require("config.keymaps")

-- 2. 加载插件管理器 (Lazy.nvim)
require("config.lazy")

vim.lsp.set_log_level("DEBUG")
