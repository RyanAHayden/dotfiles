-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

-- map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
-- map("n", "<A-K>", "i<CR><Esc>", { desc = "Split line at cursor" })

-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
-- map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
-- map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- vim.keymap.set("n", "<leader>K", "i<CR><Esc>", { desc = "Split line at cursor" })
-- vim.keymap.set("n", "<leader>,")
-- vim.keymap.set("v", "K", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
-- vim.keymap.set("n", "<leader>cd", vim.lsp.buf.hover, { desc = "Hover documentation" })
