-- lua/config/options.lua
local opt = vim.opt

-- Dagerous no backup file
opt.backup = false
opt.writebackup = false
opt.swapfile = true

-- File encoding
opt.fileencoding = "UTF-8"

-- Something about cmp pop up menu and the cmd
opt.pumheight = 10
opt.completeopt = { "menuone", "noselect" }
opt.cmdheight = 0

-- Show
opt.conceallevel = 0

-- Undo history
opt.undofile = false

-- Auto save
opt.autowriteall = false

-- Enable wrap
opt.wrap = true
opt.display:append("lastline")

-- New a split window on the right/below of the window
opt.splitright = true
opt.splitbelow = true


-- Move the cursor to next/previous line
vim.cmd "set whichwrap+=<,>,[,],h,l"

-- "-" is part of a word
vim.cmd [[set iskeyword+=-]]

vim.g.editorconfig = false

-- 基础设置
opt.number = true          -- 显示行号
opt.relativenumber = true  -- 相对行号 (方便跳转)
opt.scrolloff = 5          -- 光标上下保留8行
opt.sidescrolloff = 5
opt.mouse = "a"            -- 允许鼠标操作
opt.clipboard = "unnamedplus" -- 使用系统剪贴板

-- 缩进 (默认 4 空格)
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 搜索
opt.ignorecase = true      -- 搜索忽略大小写
opt.smartcase = true       -- 如果包含大写则不忽略
opt.hlsearch = true        -- 高亮搜索结果

-- 性能与外观
opt.termguicolors = true   -- 开启真彩色
opt.signcolumn = "yes"     -- 总是显示左侧符号列 (防止抖动)
opt.updatetime = 250       -- 缩短更新时间 (提升 gitsigns 响应)
opt.timeoutlen = 300       -- 缩短快捷键等待时间

-- 设置 Leader 键为空格
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 当进入 Quickfix (qf) 窗口时，强制开启光标行高亮
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.opt_local.cursorline = true
        -- 可选：禁止折行，让列表看起来更整洁
        vim.opt_local.wrap = false
        -- 可选：显示绝对行号方便跳转
        vim.opt_local.number = true
    end,
})

-- Restore cursor
vim.cmd [[autocmd BufRead * autocmd FileType <buffer> ++once if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]

-- Set highlight for trailing spaces
vim.api.nvim_set_hl(0, "TrailingSpace", { bg = '#87787B' })
vim.fn.matchadd("TrailingSpace", "\\s\\+$", -1)
local augroup_trailing = vim.api.nvim_create_augroup("trailing_highlight_cmds", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "alpha",
    group = augroup_trailing,
    command = "call clearmatches()"
})

