return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
      end,
    }
    local filename = {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
    }
    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end
    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }
    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
      cond = hide_in_width,
    }

    -- Custom theme with transparent background
    local custom_nord = require 'lualine.themes.nord'

    -- Safely make all backgrounds transparent
    local function make_transparent(theme_table)
      if type(theme_table) == 'table' then
        for _, section in pairs(theme_table) do
          if type(section) == 'table' then
            section.bg = 'NONE'
          end
        end
      end
    end

    -- Apply transparent background to all mode sections
    if custom_nord.normal then
      make_transparent(custom_nord.normal)
    end
    if custom_nord.insert then
      make_transparent(custom_nord.insert)
    end
    if custom_nord.visual then
      make_transparent(custom_nord.visual)
    end
    if custom_nord.replace then
      make_transparent(custom_nord.replace)
    end
    if custom_nord.command then
      make_transparent(custom_nord.command)
    end
    if custom_nord.inactive then
      make_transparent(custom_nord.inactive)
    end

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = custom_nord, -- Use the modified theme
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
