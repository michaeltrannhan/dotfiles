vim.g.mapleader = ' '
vim.opt.timeoutlen = 1000

local keymap = vim.keymap
local nnoremap = require('noremap').nnoremap

keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

nnoremap('<Leader>pv', '<cmd>Ex<CR>')
