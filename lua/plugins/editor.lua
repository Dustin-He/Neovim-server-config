-- lua/plugins/editor.lua
local env = require("utils.env")

local function get_query_driver_list()
    -- 1. 定义我们想允许的编译器名称
    local executables = {
        "clang", "clang++",
        "gcc", "g++", "c++",
        "nvcc", "cuda-gdb" -- 增加 nvcc
    }

    local drivers = {}

    -- 2. 总是添加一些标准的绝对路径作为“保底”
    -- 这样即使 PATH 里找不到，也能覆盖标准安装位置
    local standard_paths = {
        "/usr/bin/clang*",
        "/usr/bin/gcc*",
        "/usr/bin/g++*",
        "/usr/local/cuda/bin/nvcc*" -- 标准 CUDA 路径
    }
    for _, p in ipairs(standard_paths) do
        table.insert(drivers, p)
    end

    -- 3. 动态查找 PATH 中的编译器
    for _, exe in ipairs(executables) do
        local path = vim.fn.exepath(exe)
        if path ~= "" then
            -- 如果找到了 (例如 /home/user/anaconda3/bin/gcc)
            -- 我们添加 /home/user/anaconda3/bin/gcc* 以匹配 gcc-9, gcc-11 等
            table.insert(drivers, path .. "*")
        end
    end

    -- 4. 去重并合并为逗号分隔字符串
    -- (简单的去重逻辑，防止 PATH 里就是 /usr/bin 时重复添加)
    local unique_drivers = {}
    local hash = {}
    for _, v in ipairs(drivers) do
        if not hash[v] then
            unique_drivers[#unique_drivers + 1] = v
            hash[v] = true
        end
    end

    return table.concat(unique_drivers, ",")
end

return {
    -- 1. Treesitter (语法高亮)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            install_dir = vim.fn.stdpath('data') .. '/site',
            -- 远程只安装核心语言，避免下载编译太久
            ensure_installed = env.is_minimal and { "c", "cpp", "python", "lua", "bash", "cuda", "vim", "vimdoc" },

            highlight = {
                enable = true,
                -- 大文件禁用高亮 (超过 100KB)
                disable = function(_, buf)
                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter").setup(opts)
        end
    },

    -- 2. Lazydev
    {
        "folke/lazydev.nvim",
        ft = "lua", -- 仅在打开 lua 文件时加载
        opts = {
            library = {
                -- 当你输入 "vim." 时，自动加载 vim 的类型定义
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- 3. LSP 配置 (核心部分)
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },

        -- -- 极简模式手动启动，否则自动
        -- cmd = env.is_minimal and "LspStart" or nil,
        -- event = env.is_minimal and {} or { "BufReadPre", "BufNewFile" },

        config = function()
            -- 核心 LSP 快捷键配置
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(args)
                    -- 定义一个方便的辅助函数
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
                    end

                    -- 1. 查看详细报错 (这是你最需要的)
                    -- 按 gl (Go Line) 查看当前行的完整错误信息
                    map("n", "gl", vim.diagnostic.open_float, "Show Diagnostic Float")

                    -- 2. 跳转报错
                    map("n", "[d", "<cmd>lua vim.diagnostic.jump({count=-1, float=true})<CR>", "Previous Diagnostic")
                    map("n", "]d", "<cmd>lua vim.diagnostic.jump({count=1, float=true})<CR>", "Next Diagnostic")
                    map('n', '<space>q', vim.diagnostic.setloclist, "Diagnostic.setloclist")

                    -- 3. 核心跳转
                    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")   -- 跳转定义
                    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration") -- 跳转声明 (C/C++头文件)
                    map("n", "gr", vim.lsp.buf.references, "References")         -- 查看引用
                    map("n", "gh", vim.lsp.buf.hover, "Hover Documentation")     -- 查看文档/类型信息

                    -- 4. 代码操作 (Code Action)
                    -- 重要：Ruff 的自动修复、导包修复都需要用这个
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

                    -- 5. 重命名变量
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")

                    --- 6. 代码格式化
                    map('n', '<space>f', function() vim.lsp.buf.format { async = true } end, "Format")
                end,
            })

            -- 获取 Blink 的 capabilities
            local base_capabilities = require('blink.cmp').get_lsp_capabilities()

            -- === 定义所有 LSP 服务器配置 ===
            -- key: server name, value: 配置 table
            -- bin: 用于检测二进制是否存在的命令 (可选，默认等于 key)
            local servers = {
                -- 1. LuaLS
                lua_ls = {
                    bin = "lua-language-server",
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            workspace = {
                                library = {
                                    [vim.fn.stdpath("config")] = true,
                                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                    ["${3rd}/luv/library"] = true
                                }
                            },
                            telemetry = { enable = false },
                        },
                    },
                },

                -- 2. Clangd
                clangd = {
                    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--query-driver=" .. get_query_driver_list(), -- 动态调用
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                    },
                },

                -- 3. Pyright
                pyright = {
                    bin = "pyright-langserver",
                    on_init = function(client)
                        -- 动态识别 venv/conda 路径
                        local python_path = vim.fn.exepath("python")
                        if python_path and python_path ~= "" then
                            client.config.settings.python.pythonPath = python_path
                        end
                    end,
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "openFilesOnly",
                                typeCheckingMode = "basic",
                            },
                        },
                    },
                },

                -- 4. Ruff
                ruff = {
                    on_attach = function(client, _)
                        if client.server_capabilities then
                            client.server_capabilities.hoverProvider = false
                        end
                    end,
                }
            }

            -- === 统一加载逻辑 (适配 Nvim 0.10 和 0.11) ===
            local lspconfig = require("lspconfig")

            for name, opts in pairs(servers) do
                -- 1. 检查二进制是否存在
                local binary = opts.bin or name
                -- 如果 opts.cmd 存在且是 table，取第一个元素作为 binary 检查
                if opts.cmd and type(opts.cmd) == "table" then
                    binary = opts.cmd[1]
                end

                if vim.fn.executable(binary) == 1 then
                    -- 2. 注入 capabilities
                    opts.capabilities = base_capabilities
                    -- 清理自定义属性以免传给 LSP 报错
                    opts.bin = nil

                    -- 3. 版本分支处理
                    if vim.lsp.config and vim.lsp.enable then
                        -- [Nvim 0.11+ 新方式]
                        -- 从 nvim-lspconfig 获取默认配置，并与用户配置合并
                        -- 注意：configs[name] 可能不存在，需要保护
                        local config_def = require("lspconfig.configs")[name]
                        local defaults = config_def and config_def.default_config or {}

                        -- 合并配置
                        local final_config = vim.tbl_deep_extend("force", defaults, opts)

                        -- 注册并启用
                        vim.lsp.config[name] = final_config
                        vim.lsp.enable(name)
                    else
                        -- [Nvim 0.10 旧方式]
                        lspconfig[name].setup(opts)
                    end
                end
            end
        end
    }
}
