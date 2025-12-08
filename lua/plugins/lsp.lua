return {
  -- -- For Ruby
  -- {
  --     "adam12/ruby-lsp.nvim",
  --     dependencies = {
  --         "nvim-lua/plenary.nvim",
  --         "neovim/nvim-lspconfig",
  --     },
  --     config = true,
  -- },
  -- -------------------------------------

  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    -- "saghen/blink.cmp",
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
        -- Buffer local mappings
        -- Check `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- keymaps
        opts.desc = 'Show LSP references'
        vim.keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        vim.keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts) -- show lsp type definitions

        opts.desc = 'See available code actions'
        vim.keymap.set({ 'n', 'v' }, '<leader>vca', function()
          vim.lsp.buf.code_action()
        end, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = 'Smart rename'
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = 'Show buffer diagnostics'
        vim.keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show  diagnostics for file

        opts.desc = 'Show line diagnostics'
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = 'Show documentation for what is under cursor'
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = 'Restart LSP'
        vim.keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts) -- mapping to restart lsp if necessary

        vim.keymap.set('i', '<C-h>', function()
          vim.lsp.buf.signature_help()
        end, opts)
      end,
    })

    --NOTE: Diagnostics toggle code added later using ChatGPT
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
    -- NOTE : Moved all this to Mason including local variables
    -- used to enable autocompletion (assign to every lsp server config)
    -- local capabilities = cmp_nvim_lsp.default_capabilities()
    -- Change the Diagnostic symbols in the sign column (gutter)

    -- Define sign icons for each severity

    local signs = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = '󰠠 ',
      [vim.diagnostic.severity.INFO] = ' ',
    }

    -- Set the diagnostic config with all icons
    vim.diagnostic.config {
      signs = {
        text = signs, -- Enable signs in the gutter
      },
      virtual_text = true, -- Specify Enable virtual text for diagnostics
      -- virtual_text = false, underline = true, -- Specify Underline diagnostics update_in_insert = false, -- Keep diagnostics active in insert mode
    }

    -- NOTE :
    -- Moved back from mason_lspconfig.setup_handlers from mason.lua file
    -- as mason setup_handlers is deprecated & its causing issues with lsp settings
    --
    -- Setup servers using vim.lsp.config (migrated from lspconfig)
    -- Each server automatically starts when filetypes match and root_markers are found

    -- Config lsp servers here
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

    -- ts_ls (replaces tsserver) - For Node.js/npm projects including Vue
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
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

    -- pyright
    vim.lsp.config('pyright', {
      cmd = { 'pyright-langserver', '--stdio' },
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
        python = {
          -- Added later using ChatGPT -----------------------------------------------------------------
          pythonPath = (function()
            -- Try Poetry first
            local poetry_venv = vim.fn.trim(vim.fn.system 'poetry env info -p 2>/dev/null')
            if vim.v.shell_error == 0 and poetry_venv ~= '' then
              return poetry_venv .. '/bin/python'
            end

            -- Try local venv
            if vim.fn.executable 'venv/bin/python' == 1 then
              return 'venv/bin/python'
            end

            -- Try .venv
            if vim.fn.executable '.venv/bin/python' == 1 then
              return '.venv/bin/python'
            end

            -- Fall back to system python
            return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
          end)(),
          --------------------------------------------------------------------------------------------------
          analysis = {
            typeCheckingMode = 'basic', -- or "strict" if you want stricter checks
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'workspace', -- better for Django multi-file projects
            extraPaths = { './', 'apps' }, -- optional: helpful if Django apps are in custom folders
          },
        },
      },
    })

    -- ruff
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

    -- -- solargraph
    -- vim.lsp.config('solargraph', {
    --   capabilities = capabilities,
    --   cmd = { 'solargraph', 'stdio' },
    --   filetypes = { 'ruby' },
    --   root_markers = { 'Gemfile', '.git' },
    --   settings = {
    --     solargraph = {
    --       diagnostics = true,
    --       completion = true,
    --       formatting = true,
    --     },
    --   },
    -- })
    --
    vim.lsp.config('solargraph', {
      capabilities = capabilities,
      cmd = { 'bundle', 'exec', 'solargraph', 'stdio' }, -- Changed this line
      filetypes = { 'ruby' },
      root_markers = { 'Gemfile', '.git' },
      settings = {
        solargraph = {
          diagnostics = false,
          completion = true,
          formatting = false,
          useBundler = true, -- Changed to true
        },
      },
    }) -- vue-language-server (Vue Language Server) with proper TypeScript integration
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

    -- NOTE: Enable all servers - they will auto-start based on filetypes and root_markers
    -- REMOVED DENOLS from this list!
    local servers = {
      'lua_ls',
      'emmet_ls',
      'emmet_language_server',
      'ts_ls',
      'tailwindcss',
      'pyright',
      'ruff',
      'solargraph',
      'vue_ls',
      'html',
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    -- HACK: If using Blink.cmp Configure all LSPs here

    -- ( comment the ones in mason )
    -- local capabilities = require("blink.cmp").get_lsp_capabilities() -- Import capabilities from blink.cmp

    -- Configure lua_ls
    -- vim.lsp.config("lua_ls", {
    --     cmd = { "lua-language-server" },
    --     filetypes = { "lua" },
    --     root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    --     capabilities = capabilities,
    --     settings = {
    --         Lua = {
    --             diagnostics = {
    --                 globals = { "vim" },
    --             },
    --             completion = {
    --                 callSnippet = "Replace",
    --             },
    --             workspace = {
    --                 library = {
    --                     [vim.fn.expand("$VIMRUNTIME/lua")] = true,
    --                     [vim.fn.stdpath("config") .. "/lua"] = true,
    --                 },
    --             },
    --         },
    --     },
    -- })
    --
    -- -- Configure tsserver (TypeScript and JavaScript)
    -- vim.lsp.config("ts_ls", {
    --     cmd = { "typescript-language-server", "--stdio" },
    --     filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    --     root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
    --     capabilities = capabilities,
    --     single_file_support = false,
    --     on_attach = function(client, bufnr)
    --         -- Disable formatting if you're using a separate formatter like Prettier
    --         client.server_capabilities.documentFormattingProvider = false
    --     end,
    --     init_options = {
    --         preferences = {
    --             includeCompletionsWithSnippetText = true,
    --             includeCompletionsForImportStatements = true,
    --         },
    --     },
    -- })

    -- Add other LSP servers as needed, e.g., gopls, eslint, html, etc.
    -- vim.lsp.config("gopls", { cmd = { "gopls" }, filetypes = { "go", "gomod", "gowork", "gotmpl" }, root_markers = { "go.work", "go.mod", ".git" } })
    -- vim.lsp.config("html", { cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" }, root_markers = { ".git" } })
    -- vim.lsp.config("cssls", { cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css", "scss", "less" }, root_markers = { ".git" } })

    -- Enable additional servers
    -- vim.lsp.enable("gopls")
    -- vim.lsp.enable("html")
    -- vim.lsp.enable("cssls")
  end,
}
