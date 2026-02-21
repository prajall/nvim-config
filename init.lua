require 'core.options' -- Load general options
require 'core.keymaps' -- Load general keymaps
require 'core.snippets' -- Custom code snippets

-- Set up the Lazy plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = 'unnamedplus'
vim.opt.cmdheight = 0
vim.opt.guifont = 'JetBrainsMono Nerd Font Light:h12'
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#2d3748' })
-- vim.opt.mouse = ''
-- Hide top bufferline
vim.opt.showtabline = 0 -- hides the tabline
vim.opt.wrap = true

-- Remove relative line number
vim.opt.number = true
vim.opt.relativenumber = false

-- Set up plugins
require('lazy').setup {
  require 'plugins.neotree',
  require 'plugins.colortheme',
  -- require 'plugins.bufferline',
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.telescope',
  require 'plugins.lsp',
  require 'plugins.autocompletion',
  require 'plugins.gitsigns',
  require 'plugins.alpha',
  require 'plugins.indent-blankline',
  require 'plugins.misc',
  require 'plugins.comment',
  require 'plugins.mason',
  require 'plugins.conform',
  require 'plugins.harpoon',
  require 'plugins.diffview',
}

require('nvim-treesitter.install').update { with_sync = true }
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
vim.keymap.set('i', 'jj', '<Esc>')
