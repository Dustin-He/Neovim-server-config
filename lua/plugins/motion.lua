-- lua/plugins/motion.lua
local env = require("utils.env")

return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                -- 1. 搜索模式配置 (/ 或 ?)
                search = {
                    enabled = false,
                },
                -- 2. Char 模式配置 (f, t, F, T)
                char = {
                    enabled = false,
                    jump_labels = not env.is_ssh, -- 如果网络太差，甚至可以关掉标签，只用它增强高亮
                },
            },
            highlight = {
                backdrop = false,
            },

            prompt = {
                enabled = not env.is_ssh, -- SSH 下关闭底部的提示浮窗
            },
        },
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    }
}
