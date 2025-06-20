-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map jk to escape in insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })

-- Map B and E for line beginning and end
vim.keymap.set({ "n", "v" }, "B", "0", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v" }, "E", "$", { desc = "Go to end of line" })

