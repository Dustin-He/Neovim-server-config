-- lua/plugins/ui.lua
local env = require("utils.env")

return {
    -- 1. 主题 (Tokyonight)
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                -- SSH 环境下关闭透明背景，防止渲染问题
                transparent = not env.is_ssh,
                styles = {
                    -- SSH 环境下关闭斜体 (很多老旧终端不支持)
                    comments = { italic = not env.is_ssh },
                    keywords = { italic = not env.is_ssh },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- 2. 状态栏 (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function()
            -- 远程模式配置 (简化图标和分隔符)
            if env.is_minimal then
                return {
                    options = {
                        theme = "tokyonight",
                        icons_enabled = false, -- 关闭图标
                        section_separators = '',   -- 使用纯文本分隔
                        component_separators = '|',
                    },
                    sections = {
                        lualine_a = {'mode'},
                        lualine_b = {'branch'},
                        lualine_c = {'filename'},
                        lualine_x = {'filetype'},
                        lualine_y = {'progress'},
                        lualine_z = {'location'}
                    }
                }
            else
                -- 本地高性能模式配置
                return {
                    options = {
                        theme = "tokyonight",
                        component_separators = '|',
                        section_separators = { left = '', right = '' },
                    },
                    sections = {
                        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
                    },
                }
            end
        end
    },

    -- 3. Gitsigns (Git 状态)
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- 远程 SSH 环境下，减少刷新频率
            update_debounce = env.is_ssh and 300 or 100,
            numhl = false, -- 关闭行号高亮以减少渲染
        }
    },

}
