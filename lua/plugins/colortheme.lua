return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha', -- options: latte, frappe, macchiato, mocha
      transparent_background = true,
      integrations = {
        treesitter = true,
        lsp_trouble = true,
        mason = true,
        cmp = true,
        gitsigns = true,
        telescope = true,
        nvimtree = true,
        which_key = true,
        lsp_saga = true,
        indent_blankline = {
          enabled = true,
          scope_color = 'sapphire',
          colored_indent_levels = false,
        },
      },
    }

    -- Load the colorscheme
    vim.cmd.colorscheme 'catppuccin'

    -- Toggle background transparency
    local bg_transparent = true
    local toggle_transparency = function()
      bg_transparent = not bg_transparent
      require('catppuccin').setup { transparent_background = bg_transparent }
      vim.cmd.colorscheme 'catppuccin'
    end

    vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })
  end,
}
