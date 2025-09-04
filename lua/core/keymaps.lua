-- Set leader key

local opts = { noremap = true, silent = true }
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Buffers
-- vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
-- vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
-- vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
-- vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

vim.keymap.set('n', '<leader>bn', ':bnext<CR>', opts) -- next buffer
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', opts) -- previous buffer
vim.keymap.set('n', '<Tab>', ':b#<CR>', opts) -- toggle last buffer

vim.keymap.set('n', '<leader>bd', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local alternate = vim.fn.bufnr("#")
  local next_buf = vim.fn.bufnr("n")

  if vim.api.nvim_buf_is_valid(alternate) and vim.bo[alternate].buflisted then
    vim.cmd("buffer #")
  elseif vim.api.nvim_buf_is_valid(next_buf) and vim.bo[next_buf].buflisted then
    vim.cmd("bnext")
  end

  vim.cmd("bdelete " .. bufnr)
end, opts)


-- Window management
vim.keymap.set('n', '<leader>v', '<w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>h', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Auto-import keymaps (VS Code-like functionality)
-- Quick auto-import - automatically imports the symbol under cursor
vim.keymap.set('n', '<leader>ai', function()
  -- Get the word under cursor
  local word = vim.fn.expand '<cword>'
  if word == '' then
    vim.notify('No symbol under cursor', vim.log.levels.WARN)
    return
  end

  -- Request code actions for auto-import
  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { 'source.addMissingImports.ts', 'source.organizeImports.ts', 'quickfix' },
    diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 }),
  }

  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx)
    if err or not result or #result == 0 then
      -- Fallback: try general code action
      vim.lsp.buf.code_action()
      return
    end

    -- Look for import-related actions
    local import_actions = {}
    for _, action in ipairs(result) do
      if action.title and (action.title:match '[Ii]mport' or action.title:match '[Aa]dd' or action.title:match '[Ff]ix') then
        table.insert(import_actions, action)
      end
    end

    if #import_actions == 1 then
      -- Auto-apply if there's only one import action
      local action = import_actions[1]
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
      vim.notify('Auto-imported: ' .. word, vim.log.levels.INFO)
    else
      -- Show code action menu if multiple options or no specific import actions
      vim.lsp.buf.code_action()
    end
  end)
end, { desc = 'Auto-import symbol under cursor' })

-- Organize imports (similar to VS Code's organize imports)
vim.keymap.set('n', '<leader>oi', function()
  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { 'source.organizeImports.ts', 'source.organizeImports' },
    diagnostics = {},
  }

  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx)
    if err or not result or #result == 0 then
      vim.notify('No organize imports action available', vim.log.levels.WARN)
      return
    end

    -- Apply the first organize imports action
    local action = result[1]
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
    elseif action.command then
      vim.lsp.buf.execute_command(action.command)
    end
    vim.notify('Imports organized', vim.log.levels.INFO)
  end)
end, { desc = 'Organize imports' })

-- Add missing imports for entire file
vim.keymap.set('n', '<leader>am', function()
  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { 'source.addMissingImports.ts', 'source.addMissingImports' },
    diagnostics = vim.diagnostic.get(0),
  }

  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx)
    if err or not result or #result == 0 then
      vim.notify('No missing imports to add', vim.log.levels.INFO)
      return
    end

    -- Apply all missing import actions
    for _, action in ipairs(result) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
    end
    vim.notify('Added missing imports', vim.log.levels.INFO)
  end)
end, { desc = 'Add all missing imports' })
