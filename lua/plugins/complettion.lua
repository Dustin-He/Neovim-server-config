-- lua/plugins/completion.lua
local env = require("utils.env")

return {
    {
        "saghen/blink.cmp",
        version = "v1.*", -- 强制使用预编译版本 (无需 cargo)
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- keymap = { preset = 'default' },
            keymap = {
                preset = 'super-tab',
                ['<Up>'] = { 'select_prev', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<C-j>'] = { 'select_next', 'fallback' },
                ['<C-k>'] = { 'select_prev', 'fallback' },
                ['<C-u>'] = { function(cmp) return cmp.select_prev({ count = 5 }) end },
                ['<C-d>'] = { function(cmp) return cmp.select_next({ count = 5 }) end },
                -- disable a keymap from the preset
                ['<M-,>'] = { 'hide' }, -- or {}
                -- show with a list of providers
                ['<M-.>'] = { 'show' },
                ['<C-p>'] = { function(cmp) cmp.scroll_documentation_up(4) end },
                ['<C-n>'] = { function(cmp) cmp.scroll_documentation_down(4) end },
                ['<C-space>'] = { 'hide_documentation' },
                ['<C-e>'] = { 'show_documentation' }
            },

            appearance = {
                use_nvim_cmp_as_default = true,
                -- 远程环境如果没有 Nerdfont，设为 'mono'
                nerd_font_variant = 'mono',
            },

            -- 签名提示
            signature = { enabled = true },

            sources = {
                default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'cmdline' },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },

            cmdline = {
                enabled = true,
                -- 使用专门的 cmdline 键位预设
                -- 默认是: Tab 选择下一个，Shift+Tab 上一个，Enter 确认
                keymap = {
                    preset = 'inherit',
                },


                -- 根据模式动态选择补全源
                sources = function()
                    local type = vim.fn.getcmdtype()
                    -- 搜索模式 (/ 或 ?) -> 使用 buffer 内容补全
                    if type == '/' or type == '?' then
                        return { 'buffer' }
                    end
                    -- 命令模式 (:) -> 使用 vim 命令 和 path 路径补全
                    if type == ':' then
                        return { 'cmdline', 'path', 'buffer' }
                    end
                    return {}
                end,

                -- 命令行补全窗口的独立设置
                completion = {
                    -- 远程优化：命令行打字很快，必须关闭 Ghost Text，否则会非常卡
                    ghost_text = { enabled = false },
                    -- 自动弹出菜单
                    menu = { auto_show = true },
                }
            },

            completion = {
                -- 文档弹窗配置
                documentation = {
                    -- 远程 SSH 环境下，自动弹窗会造成输入卡顿，建议关闭自动显示
                    auto_show = not env.is_ssh,
                    auto_show_delay_ms = 500,
                },

                -- 幽灵文本 (光标后的灰色建议)
                -- 远程网络延迟会导致这个功能让光标乱跳，必须关闭
                ghost_text = {
                    enabled = not env.is_ssh,
                },
            },
        },
        opts_extend = { "sources.default" }
    }
}
