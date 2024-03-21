local has_baleia, baleia = pcall(require, "baleia")

if has_baleia then
  local b = baleia.setup()
  b.automatically(vim.api.nvim_get_current_buf())
end
