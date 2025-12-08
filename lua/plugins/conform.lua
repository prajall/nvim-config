return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require('conform')
    
    conform.setup {
      formatters_by_ft = {
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        vue = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        less = { 'prettier' },
        html = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        graphql = { 'prettier' },
        handlebars = { 'prettier' },
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        ruby = { 'rubocop' },
      },
      -- format_on_save can cause issues, so let's make it more reliable
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
      -- Optional: notify on format errors
      notify_on_error = true,
    }

    -- Create commands to toggle formatting
    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting globally
        vim.g.disable_autoformat = true
      else
        -- FormatDisable will disable formatting for current buffer
        vim.b.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })

    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })

    -- Keymap to manually format
    vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = 'Format file or range (in visual mode)' })

    -- Optional: keymap to toggle format on save
    vim.keymap.set('n', '<leader>tf', function()
      if vim.b.disable_autoformat or vim.g.disable_autoformat then
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
        print('Format on save: enabled')
      else
        vim.b.disable_autoformat = true
        print('Format on save: disabled')
      end
    end, { desc = 'Toggle format on save' })
  end,
}
