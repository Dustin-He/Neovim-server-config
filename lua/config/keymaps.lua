-- lua/config/keymaps.lua
local map = vim.keymap.set

map("i", "jk", "<ESC>", { desc = "Escape" })

local opts = { desc = "" }

-- Visual Mode --
-- Move multiple lines
map("v", "<leader>j", ":m '>+1<CR>gv", opts)
map("v", "<leader>k", ":m '<-2<CR>gv", opts)
-- 更好的缩进体验 (选中后按 < 或 > 不会丢失选中状态)
map("v", ">", ">gv", opts)
map("v", "<", "<gv", opts)
-- Paste in visual mode
map("v", "p", '"_dP', opts)

-- Normal Mode --
-- 移动
vim.cmd [[nnoremap <silent><expr> j (v:count > 0 ? "m'" . v:count : "") . 'j']]
vim.cmd [[nnoremap <silent><expr> k (v:count > 0 ? "m'" . v:count : "") . 'k']]
map("n", "J", "10j", { desc = "Move down ten rows" })
map("n", "K", "10k", { desc = "Move up ten rows" })
map("n", "H", "10h", { desc = "Move left ten letters" })
map("n", "L", "10l", { desc = "Move right ten letters" })
map("n", "W", "5w", { desc = "Move forward five words" })
map("n", "B", "5b", { desc = "Move back five words" })
map("v", "J", "10j", { desc = "Move down ten rows" })
map("v", "K", "10k", { desc = "Move up ten rows" })
map("v", "H", "5h", { desc = "Move left five letters" })
map("v", "L", "5l", { desc = "Move right five letters" })
map("v", "W", "5w", { desc = "Move forward five words" })
map("v", "B", "5b", { desc = "Move back five words" })

-- 窗口导航 (Ctrl + hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
-- Split window
map("n", "<leader>sv", "<C-w>v", {desc = "Split vertical window"})
map("n", "<leader>sh", "<C-w>s", {desc = "Split horizontal window"})
-- Resize window
map("n", "<S-Up>", ":resize +1<CR>", opts)
map("n", "<S-Down>", ":resize -1<CR>", opts)
map("n", "<S-Left>", ":vertical resize +1<CR>", opts)
map("n", "<S-Right>", ":vertical resize -1<CR>", opts)
-- Change buffer
map("n", "<leader>n", ":bn<CR>", {desc = "Go to next buffer"})
map("n", "<leader>p", ":bp<CR>", {desc = "Go to previous buffer"})

-- 清除搜索高亮 (Esc)
map("n", "<leader>hl", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })

require('utils').set_loclist_keymap()
