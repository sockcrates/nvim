return {
  'olimorris/codecompanion.nvim',
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('codecompanion').setup {
      strategies = {
        chat = {
          adapter = 'copilot',
        },
        cmd = {
          adapter = 'copilot',
        },
        inline = {
          adapter = 'copilot',
        },
      },
    }

    vim.keymap.set(
      'n',
      '<leader>ci',
      '<cmd>CodeCompanion<CR>',
      { desc = 'Open CodeCompanion Inline Prompt' }
    )

    vim.keymap.set(
      'n',
      '<leader>cc',
      '<cmd>CodeCompanionChat<CR>',
      { desc = 'Open CodeCompanion Chat' }
    )

    vim.keymap.set(
      'n',
      '<leader>co',
      '<cmd>CodeCompanionActions<CR>',
      { desc = 'Open CodeCompanion Actions' }
    )
  end,
}
