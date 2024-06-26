local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    require("config.plugins.statusline"),
    require("config.plugins.telescope").config,
    -- require("config.plugins.winbar"),
    require("config.plugins.yank"),
    require("config.plugins.treesitter"),
    require("config.plugins.wilder"),
    require("config.plugins.snippets"),
    require("config.plugins.lspconfig").config,
    require("config.plugins.debugger"),
    require("config.plugins.autocomplete").config,
}, {})
