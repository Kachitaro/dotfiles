require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Chia dọc màn hình (Vertical Split)" })
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Bật/tắt NvimTree" })
map({ "n", "i" }, "<C-e>", "<cmd>VietnameseToggle<CR>", { desc = "Toggle tiếng Việt (Telex/VNI)" })
map("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })