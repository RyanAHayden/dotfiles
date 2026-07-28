-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ponytail: drop shada oldfiles entries like "~./bashrc" (tilde-user syntax).
-- fnamemodify(":p") on these spawns a shell from the projects picker's async
-- callback, which nvim can't wait() on there and aborts (SIGABRT). Filter, don't shell out.
vim.v.oldfiles = vim.tbl_filter(function(f)
  return not f:match("^~[^/]")
end, vim.v.oldfiles)
