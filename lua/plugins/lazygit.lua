-- lua/plugins/git.lua
return {
    -- 1. Gitsigns (之前已经在 editor.lua 里的话，这里可以不写，或者移过来)
    -- 既然你之前的 editor.lua 里有 gitsigns，这里我就只放 lazygit

    -- 2. LazyGit 插件
    {
        "kdheepak/lazygit.nvim",
        lazy = true;
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- 可选：加载 telescope 扩展 (如果你用 telescope 的话)
        dependencies = { "nvim-lua/plenary.nvim" },

        keys = {
            -- 打开完整 Git 窗口
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
        config = function()
            -- 远程优化：背景透明度 (如果终端本身透明，这里设为 true 会更好看)
            -- 但为了防卡顿，通常默认即可
            vim.g.lazygit_floating_window_winblend = 0

            -- 自定义窗口大小
            vim.g.lazygit_floating_window_scaling_factor = 0.9

            -- 核心：当在 LazyGit 里面按 q 退出时，不要用 :bd 关闭，而是隐藏浮窗
            -- 这样下次打开秒开，不用重新加载
            vim.g.lazygit_use_neovim_remote = 1
        end,
    }
}
