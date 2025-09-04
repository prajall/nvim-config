return {
  -- auto-session: automatic session management
  {
    'rmagatti/auto-session',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-telescope/telescope-project.nvim',
    },
    config = function()
      -- Setup auto-session
      require('auto-session').setup {
        auto_session_enable_last_session = true, -- auto restore last session
        auto_session_root_dir = vim.fn.stdpath 'data' .. '/sessions/',
        auto_session_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_suppress_dirs = { '~/', '/' }, -- don’t save sessions for these
      }

      -- Telescope integration for sessions
      require('telescope').load_extension 'session-lens'
      vim.keymap.set('n', '<leader>fs', function()
        require('auto-session.session-lens').search_session()
      end, { desc = 'Find session' })

      -- Telescope integration for projects
      require('telescope').load_extension 'project'
      vim.keymap.set('n', '<leader>fp', '<cmd>Telescope project<CR>', { desc = 'Find project' })
    end,
  },
}
