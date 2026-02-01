-- lua/plugins/core.lua
return {
    -- 1. 文件管理器 (Oil.nvim) - 像编辑 buffer 一样管理文件
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- 如果终端支持图标
        opts = {
            view_options = {
                show_hidden = false,
            },
            float = {
                padding = 2,
                max_width = 90,
                max_height = 0,
            },
        },
    },

    -- 2. 模糊查找 (Fzf-lua)
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<cr>",     desc = "Find Files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep Text" },
            { "<leader>fb", "<cmd>FzfLua buffers<cr>",   desc = "Find Buffers" },
            { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help" },
        },
        config = function()
            require("fzf-lua").setup({
                -- 自动检测我们安装的 rg 和 fd
                files = {
                    -- 这里的 fd 是我们脚本安装的，自动生效
                    cmd = "fd --type f --hidden --follow --exclude .git",
                },
                grep = {
                    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
                },
                -- 远程优化: 禁用预览窗口的图标以提高渲染速度
                previewers = {
                    builtin = {
                        syntax_limit_b = 1024 * 100, -- 100KB 以上文件不预览高亮
                    },
                },
            })
        end
    },

    -- 3. 自动配对括号
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {}
    },

    -- 4. 注释插件 (Comment.nvim)
    {
        "numToStr/Comment.nvim",
        -- Lazy 加载：读取文件或新建文件时加载
        event = { "BufReadPost", "BufNewFile" },
        config = true, -- 使用默认配置即可
        -- 用法：
        -- gcc: 注释当前行
        -- gbc: 块注释当前行
        -- gc + 动作: 注释区域 (例如 gc3j 注释下3行)
        -- 选中区域 + gc: 注释选中区域
    },

    -- 5. 智能关闭 Buffer (Mini.bufremove)
    {
        "nvim-mini/mini.bufremove",
        version = false,
        keys = {
            -- 关闭当前 buffer，但保留窗口布局
            {
                "<leader><tab>",
                function()
                    local bd = require("mini.bufremove").delete
                    local is_modified = vim.bo.modified
                    local force = false

                    -- 1. 如果文件有修改，先询问是否保存
                    if is_modified then
                        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()),
                            "&Yes\n&No\n&Cancel")
                        if choice == 1 then     -- Yes: 保存
                            vim.cmd.write()
                        elseif choice == 2 then -- No: 不保存 (强制关闭)
                            force = true
                        else                    -- Cancel: 取消操作
                            return
                        end
                    end

                    -- 2. 检查当前是否只剩这一个 Buffer
                    -- getbufinfo({buflisted=1}) 获取所有在列表中的 buffer (排除掉插件生成的临时 buffer)
                    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
                    local is_last_buffer = #listed_buffers == 1 and
                        listed_buffers[1].bufnr == vim.api.nvim_get_current_buf()

                    -- 3. 执行操作
                    if is_last_buffer then
                        -- 如果是最后一个，直接退出 Neovim
                        if force then
                            vim.cmd("quit!")
                        else
                            vim.cmd("quit")
                        end
                    else
                        -- 否则，只移除 buffer，保留窗口布局
                        bd(0, force)
                    end
                end,
                desc = "Delete Buffer"
            },
        },
    },

    -- 6. Surroud
    {
        'nvim-mini/mini.surround',
        version = false,
        opts = {
            mappings = {
                add = '<leader>sa',       -- Add surrounding in Normal and Visual modes
                delete = '<leader>sd',    -- Delete surrounding
                replace = '<leader>sr',   -- Replace surrounding
                find = '<leader>sf',      -- Find surrounding (to the right)
                find_left = '<leader>sF', -- Find surrounding (to the left)
                highlight = '<leader>sh', -- Highlight surrounding

                suffix_last = 'l',        -- Suffix to search with "prev" method
                suffix_next = 'n',        -- Suffix to search with "next" method
            },
        }
    },

    -- 7. nvim-tmux
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
            "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    }
}
