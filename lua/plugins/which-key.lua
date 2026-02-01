local env = require("utils.env")

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        cmd = "WhichKey",
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (Which-Key)",
            },
        },
        opts = {
            -- 1. 核心远程优化：延迟设置
            -- 在 SSH 环境下，设置更长的等待时间 (500ms)，避免快速输入时频繁弹窗导致卡顿
            -- 本地环境则保持灵敏 (200ms)
            delay = env.is_ssh and 500 or 200,

            -- 2. 预设配置
            preset = "classic", -- 使用 classic 预设，渲染最简单，兼容性最好

            -- 3. 窗口样式
            win = {
                -- SSH 下建议用单线边框，渲染字符少
                border = "single",
                no_overlap = false,
                padding = { 1, 2 }, -- 减少 padding 以节省空间
            },

            disable = {
                buftypes = { "nofile" },
                filetypes = {'vim'}
            },

            -- 4. 图标设置
            icons = {
                breadcrumb = "»", -- 面包屑导航
                separator = "➜", -- 映射分割符
                group = "+", -- 组前缀
                -- 如果在某些极简 SSH 终端下图标乱码，可以将 keys 设为 false
                -- keys = vim.g.have_nerd_font and {} or false,
            },
        },
    },
}
