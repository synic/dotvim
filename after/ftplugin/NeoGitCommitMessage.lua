vim.bo.textwidth = 72
vim.bo.cindent = false
vim.api.nvim_buf_set_keymap(0, "n", "gq", "<cmd>normal gw", { desc = "Wrap" })
