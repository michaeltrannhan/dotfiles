local status, packer = pcall(require, 'packer')
if not status then
  print('Packer is not installed')
  return
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'gpanders/editorconfig.nvim'
  use 'dinhhuy258/git.nvim'
end)
