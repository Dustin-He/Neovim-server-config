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
                        icons_enabled = false,   -- 关闭图标
                        section_separators = '', -- 使用纯文本分隔
                        component_separators = '|',
                    },
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = { 'branch' },
                        lualine_c = { 'filename' },
                        lualine_x = { 'filetype' },
                        lualine_y = { 'progress' },
                        lualine_z = { 'location' }
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

    -- 4. Fold: nvim-ufo
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufReadPost", -- 打开文件后加载，不拖慢启动速度
        init = function()
            -- 必须在 setup 之前设置这些原生选项
            vim.o.foldcolumn = "1" -- 显示折叠列 (0为隐藏，1为显示一列图标)
            vim.o.foldlevel = 99   -- 打开文件时默认打开所有折叠
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        end,
        opts = {
            -- 远程优化：使用最简单的 provider 策略
            provider_selector = function(bufnr, filetype, buftype)
                -- 如果是超大文件，禁用 ufo (保护远程性能)
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                if line_count > 50000 then
                    return ""
                end
                return { "treesitter", "indent" }
            end,

            -- 自定义折叠行的显示文本 (保持简洁)
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "MoreMsg" })
                return newVirtText
            end,
        },
        keys = {
            -- 常用折叠快捷键
            { "zR", function() require("ufo").openAllFolds() end,               desc = "Open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end,              desc = "Close all folds" },
            { "zr", function() require("ufo").openFoldsExceptKinds() end,       desc = "Open fold level" },
            { "zm", function() require("ufo").closeFoldsWith() end,             desc = "Close fold level" },
            { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
        },
    },


    -- 5. statuscol
    {
        "luukvbaal/statuscol.nvim",
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                -- 远程优化：限制刷新频率，避免网络卡顿导致闪烁
                -- 虽然 statuscol 本身很快，但我们可以减少不必要的重绘
                relculright = true, -- 行号右对齐

                -- 定义列的组成部分 (Segments)
                segments = {
                    -- 1. 最左侧：Git 变更标记 (Gitsigns) 和 诊断错误点 (Diagnostics)
                    {
                        text = {
                            "%s",         -- 【暴力匹配】显示所有 Sign
                        },
                        click = "v:lua.ScSa",
                    },

                    -- 3. 中间：行号
                    {
                        text = { builtin.lnumfunc, " " }, -- 显示行号和一个空格
                        click = "v:lua.ScLa",             -- 点击行号可选中
                    },

                    -- 2. 最右侧：折叠图标 (就像 VSCode 的小箭头)
                    {
                        text = { builtin.foldfunc, "" }, -- 使用内置折叠图标
                        click = "v:lua.ScFa",            -- 点击折叠
                    },

                },
            })
        end,

        init = function()
            -- 设置诊断图标
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = "󰠠 ",
                        [vim.diagnostic.severity.INFO] = " ",
                    },
                    -- 可选：如果你希望行号也跟着变色
                    numhl = {
                        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                    },
                },
                underline = false,
                severity_sort = true,
            })
        end
    },
}
