local js_tools = nil

local look_for_linters = require 'utils.look_for_linters'
if look_for_linters.find_biome() then
  js_tools = { 'biome' }
else
  if look_for_linters.find_prettier() then
    if vim.fn.executable 'prettierd' == 1 then
      js_tools = { 'prettierd' }
    else
      js_tools = { 'prettier' }
    end
  end

  if look_for_linters.find_eslint() then
    if js_tools == nil then
      js_tools = {}
    end

    if vim.fn.executable 'eslint_d' == 1 then
      table.insert(js_tools, 1, 'eslint_d')
    else
      table.insert(js_tools, 1, 'eslint')
    end
  end
end

-- Autoformat: fixes files by modifying them.
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters = {
      clang_format = {
        prepend_args = { '--style=file', '--fallback-style=LLVM' },
      },
    },
    formatters_by_ft = {
      c = { 'clang-format' },
      javascript = js_tools,
      javascriptreact = js_tools,
      lua = { 'stylua' },
      typescript = js_tools,
      typescriptreact = js_tools,
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
