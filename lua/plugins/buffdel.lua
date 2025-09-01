return {
  'famiu/bufdelete.nvim',
  keys = {
    {
      '<leader>bd',
      function()
        require('bufdelete').bufdelete(0, false)
      end,
      desc = 'Delete buffer',
    },
  },
}
