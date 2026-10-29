-- Plugin Manager
require("config.lazy")

-- 宗教戰爭
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set ignorecase")

-- 剪貼簿:y/d/p 直接走系統剪貼簿(Wayland 下自動使用 wl-copy/wl-paste)
vim.cmd("set clipboard=unnamedplus")


-- Theme
vim.cmd.colorscheme "tokyonight"

