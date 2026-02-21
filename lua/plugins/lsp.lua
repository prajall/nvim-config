return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'antosha417/nvim-lsp-file-operations', config = true },
  },
  config = function()
    -- Get capabilities for autocompletion
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- NOTE: Global LSP configuration that applies to all servers
    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    -- NOTE: LSP Keybinds
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        -- keymaps
        opts.desc = 'Show LSP references'
        vim.keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts)

        opts.desc = 'Go to declaration'
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

        opts.desc = 'Show LSP definitions'
        vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)

        opts.desc = 'Show LSP implementations'
        vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)

        opts.desc = 'Show LSP type definitions'
        vim.keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts)

        opts.desc = 'See available code actions'
        vim.keymap.set({ 'n', 'v' }, '<leader>vca', function()
          vim.lsp.buf.code_action()
        end, opts)

        opts.desc = 'Smart rename'
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

        opts.desc = 'Show buffer diagnostics'
        vim.keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts)

        opts.desc = 'Show line diagnostics'
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)

        opts.desc = 'Show documentation for what is under cursor'
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

        opts.desc = 'Restart LSP'
        vim.keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts)

        vim.keymap.set('i', '<C-h>', function()
          vim.lsp.buf.signature_help()
        end, opts)
      end,
    })

    -- Diagnostics toggle
    local diagnostics_enabled = true
    vim.keymap.set('n', '<leader>td', function()
      diagnostics_enabled = not diagnostics_enabled

      if diagnostics_enabled then
        vim.diagnostic.show()
        vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {})
        print 'Diagnostics ON'
      else
        vim.diagnostic.hide()
        vim.lsp.handlers['textDocument/publishDiagnostics'] = function() end
        print 'Diagnostics OFF'
      end
    end)

    -- Diagnostic signs
    local signs = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = '󰠠 ',
      [vim.diagnostic.severity.INFO] = ' ',
    }

    vim.diagnostic.config {
      signs = {
        text = signs,
      },
      virtual_text = true,
    }

    -- lua_ls
    vim.lsp.config('lua_ls', {
      cmd = { 'lua-language-server' },
      filetypes = { 'lua' },
      root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git',
      },
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
          completion = {
            callSnippet = 'Replace',
          },
          workspace = {
            library = {
              [vim.fn.expand '$VIMRUNTIME/lua'] = true,
              [vim.fn.stdpath 'config' .. '/lua'] = true,
            },
          },
        },
      },
    })

    -- emmet_ls
    vim.lsp.config('emmet_ls', {
      cmd = { 'emmet-ls', '--stdio' },
      filetypes = {
        'html',
        'typescriptreact',
        'javascriptreact',
        'css',
        'sass',
        'scss',
        'less',
        'svelte',
        'htmldjango',
      },
      root_markers = { '.git' },
    })

    -- emmet_language_server
    vim.lsp.config('emmet_language_server', {
      cmd = { 'emmet-language-server', '--stdio' },
      filetypes = {
        'css',
        'eruby',
        'html',
        'javascript',
        'javascriptreact',
        'less',
        'sass',
        'scss',
        'pug',
        'typescriptreact',
        'htmldjango',
      },
      root_markers = { '.git' },
      init_options = {
        includeLanguages = {},
        excludeLanguages = {},
        extensionsPath = {},
        preferences = {},
        showAbbreviationSuggestions = true,
        showExpandedAbbreviation = 'always',
        showSuggestionsAsSnippets = false,
        syntaxProfiles = {},
        variables = {},
      },
    })

    -- ts_ls
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
      },
      root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
      single_file_support = false,
      init_options = {
        plugins = {
          {
            name = '@vue/typescript-plugin',
            location = vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/@vue/typescript-plugin',
            languages = { 'vue' },
          },
        },
        preferences = {
          includeCompletionsWithSnippetText = true,
          includeCompletionsForImportStatements = true,
        },
      },
    })

    -- tailwindcss
    vim.lsp.config('tailwindcss', {
      cmd = { 'tailwindcss-language-server', '--stdio' },
      filetypes = {
        'html',
        'htmldjango',
        'css',
        'scss',
        'sass',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
      },
      root_markers = {
        'tailwind.config.js',
        'tailwind.config.cjs',
        'tailwind.config.mjs',
        'tailwind.config.ts',
        'postcss.config.js',
        'package.json',
        '.git',
      },
      init_options = {
        userLanguages = {
          htmldjango = 'html',
        },
      },
    })

    -- pylsp (Python LSP Server)
    vim.lsp.config('pylsp', {
      cmd = { 'pylsp' },
      filetypes = { 'python' },
      root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
      },
      settings = {
        pylsp = {
          plugins = {
            -- Linting
            pylint = { enabled = true, executable = 'pylint' },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            -- Type checking
            pylsp_mypy = { enabled = true },
            -- Auto-completion
            jedi_completion = { fuzzy = true },
            -- Import sorting
            pyls_isort = { enabled = true },
            -- Formatting (if you want pylsp to format)
            autopep8 = { enabled = false },
            yapf = { enabled = false },
          },
        },
      },
    })

    -- ruff (for fast linting and formatting)
    vim.lsp.config('ruff', {
      cmd = { 'ruff', 'server', '--preview' },
      filetypes = { 'python' },
      root_markers = {
        'pyproject.toml',
        'ruff.toml',
        '.ruff.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
      },
      init_options = {
        settings = {
          args = {},
        },
      },
    })

    -- solargraph
    vim.lsp.config('solargraph', {
      capabilities = capabilities,
      cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
      filetypes = { 'ruby' },
      root_markers = { 'Gemfile', '.git' },
      settings = {
        solargraph = {
          diagnostics = false,
          completion = true,
          formatting = false,
          useBundler = true,
        },
      },
    })

    -- vue_ls
    vim.lsp.config('vue_ls', {
      capabilities = capabilities,
      cmd = { 'vue-language-server', '--stdio' },
      filetypes = { 'vue' },
      root_markers = {
        'package.json',
        'vue.config.js',
        'vite.config.js',
        'nuxt.config.js',
        'yarn.lock',
        'pnpm-lock.yaml',
        '.git',
      },
      init_options = {
        vue = {
          hybridMode = false,
        },
        typescript = {
          tsdk = vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/typescript/lib',
        },
      },
    })

    -- html
    vim.lsp.config('html', {
      cmd = { 'vscode-html-language-server', '--stdio' },
      filetypes = { 'html', 'htmldjango' },
      root_markers = { '.git', 'package.json' },
      capabilities = capabilities,
      init_options = {
        configurationSection = { 'html', 'css', 'javascript' },
        embeddedLanguages = {
          css = true,
          javascript = true,
        },
        provideFormatter = true,
      },
    })

    -- Enable all servers
    local servers = {
      'lua_ls',
      'emmet_ls',
      'emmet_language_server',
      'ts_ls',
      'tailwindcss',
      'pylsp', -- Changed from 'pyright'
      'ruff',
      'solargraph',
      'vue_ls',
      'html',
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end
  end,
}
