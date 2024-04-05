vim.g.mapleader = " "

local keymap = vim.keymap

---------------------- insert mode ----------------------
-- mode : dest keys : source keys
keymap.set("i", "jk", "<ESC>")

---------------------- visual mode ----------------------
                   --":m '>+1<CR>gv=gv
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '>-2<CR>gv=gv")

---------------------- normal mode ----------------------
keymap.set("n", "<leader>sv", "<C-w>v")
keymap.set("n", "<leader>sh", "<C-w>s")
keymap.set("n", "S", ":w<CR>")
keymap.set("n", "Q", ":q<CR>")
keymap.set("n", "<leader><CR>", ":nohlsearch<CR>")

local mode_nv = { "n", "v" }
local mode_v  = { "v" }
local mode_i  = { "i" }
local nmappings = {
    { from = "S", to = ":w<CR>" },
    { from = "Q", to = ":q<CR>" },
    { from = "`", to = "~", mode = mode_nv },

    -- movement
    -- { from = "K", to = "5k", mode = mode_nv },
    -- { from = "J", to = "5j", mode = mode_nv },
}

for _, mapping in ipairs(nmappings) do
    vim.keymap.set(mapping.mode or "n", mapping.from, mapping.to, { noremap = true })
end
