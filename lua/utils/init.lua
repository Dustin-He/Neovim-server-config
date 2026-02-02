M = {}

-- 定义一个全局的开关函数
local function toggle_loclist()
    -- local winid = vim.api.nvim_get_current_win()

    -- 1. 判断当前是否在 loclist 窗口中 (loclist 的 filetype 是 qf)
    if vim.bo[0].filetype == 'qf' then
        vim.cmd.lclose()
        return
    end

    -- 2. 如果在代码窗口，检查是否关联了打开的 loclist
    local loc_winid = vim.fn.getloclist(0, { winid = 0 }).winid
    if loc_winid ~= 0 then
        vim.cmd.lclose()            -- 已打开则关闭
    else
        vim.diagnostic.setloclist() -- 未打开则设置并打开
    end
end

-- 注册为全局快捷键 (注意这里没有 { buffer = ... })
function M.set_loclist_keymap()
    vim.keymap.set('n', '<space>q', toggle_loclist, { desc = "Toggle Diagnostic loclist" })
end

return M
