return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
    },
    'saadparwaiz1/cmp_luasnip',
    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    luasnip.config.setup {}
    
    local kind_icons = {
      Text = '󰉿',
      Method = 'm',
      Function = '󰊕',
      Constructor = '',
      Field = '',
      Variable = '󰆧',
      Class = '󰌗',
      Interface = '',
      Module = '',
      Property = '',
      Unit = '',
      Value = '󰎠',
      Enum = '',
      Keyword = '󰌋',
      Snippet = '',
      Color = '󰏘',
      File = '󰈙',
      Reference = '',
      Folder = '󰉋',
      EnumMember = '',
      Constant = '󰇽',
      Struct = '',
      Event = '',
      Operator = '󰆕',
      TypeParameter = '󰊄',
    }

    -- Function to manually trigger completion with better behavior
    local function manual_complete()
      if cmp.visible() then
        -- If menu is already visible, close it
        cmp.abort()
      else
        -- Force completion to trigger
        cmp.complete({
          config = {
            sources = {
              { name = 'nvim_lsp', priority = 1000 },
              { name = 'luasnip', priority = 750 },
              { name = 'buffer', priority = 500 },
              { name = 'path', priority = 250 },
            }
          }
        })
      end
    end

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { 
        completeopt = 'menu,menuone,noinsert',
        -- Make completion more responsive
        keyword_length = 0,  -- Show completions immediately
        get_trigger_characters = function()
          return { '.', ':', '(', '"', "'", '/', '\\' }
        end,
      },
      -- Enhanced completion behavior
      experimental = {
        ghost_text = true, -- Show ghost text for the first suggestion
      },
      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert {
        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        -- Scroll the documentation window [b]ack / [f]orward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm { 
          select = true,
          behavior = cmp.ConfirmBehavior.Insert,
        },
        -- Enhanced manual completion trigger (VS Code-like Ctrl+Space behavior)
        ['<leader>f'] = cmp.mapping(manual_complete, { 'i', 'n' }),
        
        -- Alternative keybind for manual completion (Ctrl+Space equivalent)
        -- Uncomment if you want Ctrl+Space as well
        -- ['<C-Space>'] = cmp.mapping(manual_complete, { 'i', 'n' }),
        
        -- Think of <c-l> as moving to the right of your snippet expansion.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
        
        -- Enhanced Tab behavior
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
        
        -- Enter to accept completion
        ['<CR>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          else
            fallback()
          end
        end, { 'i' }),
        
        -- Escape to close completion menu
        ['<Esc>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort()
          else
            fallback()
          end
        end, { 'i' }),
      },
      sources = cmp.config.sources({
        {
          name = 'lazydev',
          -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          group_index = 0,
        },
        { 
          name = 'nvim_lsp',
          priority = 1000, -- Higher priority for LSP completions (includes auto-imports)
          keyword_length = 0, -- Show LSP completions immediately
        },
        { 
          name = 'luasnip',
          priority = 750,
          keyword_length = 0,
        },
        { 
          name = 'buffer',
          priority = 500,
          keyword_length = 1, -- Only show buffer completions after 1 character
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end
          }
        },
        { 
          name = 'path',
          priority = 250,
          keyword_length = 0,
        },
      }),
      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
          vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
          vim_item.menu = ({
            nvim_lsp = '[LSP]',
            luasnip = '[Snippet]',
            buffer = '[Buffer]',
            path = '[Path]',
            lazydev = '[LazyDev]',
          })[entry.source.name]
          return vim_item
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      -- Performance improvements
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 200,
      },
    }

    -- Additional autocommand to ensure LSP completions work properly
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        
        -- Buffer local mappings for additional LSP features
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', '<leader>F', function()
          -- Force LSP completion in normal mode (useful for hovering over identifiers)
          vim.lsp.buf.hover()
        end, opts)
      end,
    })
  end,
}