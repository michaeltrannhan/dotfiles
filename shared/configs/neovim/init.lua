require('base')
require('plugin')
require('highlight')
require('remap')

local has = vim.fn.has
local is_win = has 'win32'

if is_win then
  require('windows')
end
