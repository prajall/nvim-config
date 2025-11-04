return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",                                   -- for autocompletion support
    { "antosha417/nvim-lsp-file-operations", config = true }, -- optional but safe
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-dap-python",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup()
    -- Capabilities (for nvim-cmp completion)
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Global LSP config
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- Keymaps when LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Show documentation"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
      end,
    })

    -- Diagnostic signs
    local signs = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    }
    vim.diagnostic.config({
      signs = { text = signs },
      virtual_text = true,
    })

    -- -------------------
    -- LSP Servers Config
    -- -------------------

    -- Lua
    vim.lsp.config("lua_ls", {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- TypeScript/JavaScript
    vim.lsp.config("ts_ls", {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
      root_markers = { "tsconfig.json", "package.json", ".git" },
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.stdpath("data")
                .. "/mason/packages/typescript-language-server/node_modules/@vue/typescript-plugin",
            languages = { "vue" },
          },
        },
      },
    })

    -- Vue
    vim.lsp.config("vue_ls", {
      cmd = { "vue-language-server", "--stdio" },
      filetypes = { "vue" },
      root_markers = {
        "package.json",
        "vue.config.js",
        "vite.config.js",
        "nuxt.config.js",
        "yarn.lock",
        "pnpm-lock.yaml",
        ".git",
      },
      init_options = {
        vue = { hybridMode = false },
        typescript = {
          tsdk = vim.fn.stdpath("data")
              .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
        },
      },
    })

    vim.lsp.config("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
            -- Django-specific settings
            extraPaths = {},
          },
        },
      },
    })

    -- Ruff (Python Linter/Formatter)
    vim.lsp.config("ruff", {
      cmd = { "ruff", "server", "--preview" },
      filetypes = { "python" },
      init_options = {
        settings = {
          -- Configure Ruff to ignore Django-specific issues
          lint = {
            select = { "E", "F", "W", "I" },
            ignore = { "E501" }, -- Ignore line too long
          },
        },
      },
    })
    vim.lsp.config("jedi_language_server", {
      cmd = { "jedi-language-server" },
      filetypes = { "python" },
    })
    -- Enable servers
    local servers = { "lua_ls", "ts_ls", "vue_ls", "pyright", "ruff", "jedi_language_server" }
    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    -- Format on save using the new API
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr }) -- new API
        for _, client in ipairs(clients) do
          if client.supports_method("textDocument/formatting") then
            vim.lsp.buf.format({ bufnr = bufnr })
            return
          end
        end
      end,
    })
  end,
}
