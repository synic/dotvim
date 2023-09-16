local status, baleia_module = pcall(require, "baleia")

if status then
  local baleia = baleia_module.setup()
  baleia.automatically(vim.api.nvim_get_current_buf())
end
