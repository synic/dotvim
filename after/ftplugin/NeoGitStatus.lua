vim.api.nvim_buf_set_keymap(0, "n", "gP", "<cmd>call system('./do pr')<cr>", { desc = "Open pr" })
vim.defer_fn(function()
  vim.cmd.normal("2")
end, 200)
