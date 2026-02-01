-- lua/utils/env.lua
local M = {}

-- 检测 SSH 环境 (SSH_CLIENT 或 SSH_TTY 存在)
M.is_ssh = os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil

-- 检测是否在 WSL (Windows Subsystem for Linux)
M.is_wsl = vim.fn.has("wsl") == 1

-- 极简模式判定：如果是 SSH，默认开启极简模式
-- 你也可以在这里加入内存检测逻辑
M.is_minimal = M.is_ssh

return M
