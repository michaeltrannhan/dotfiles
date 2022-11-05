require('base')
require('highlights')
require('maps')
require('plugins')

local has = vim.fn.has
local is_win = has "win32"

if is_win then
  require('windows')
end
