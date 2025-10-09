-- Autoformat: fixes files by modifying them.
local tooling = require 'utils.tooling'

local js_tools = nil
local eslint = tooling.find_eslint()

if tooling.find_biome() then
  js_tools = { 'biome' }
else
  if tooling.find_prettier() then
    if vim.fn.executable 'prettierd' == 1 then
      js_tools = { 'prettierd' }
    else
      js_tools = { 'prettier' }
    end
  end

  if eslint.found then
    if js_tools == nil then
      js_tools = {}
    end
    table.insert(js_tools, 'eslint_d')
  end
end

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
      black = {
        command = function()
          local _, black_path = tooling.find_black()
          return black_path or 'black'
        end,
      },
      clang_format = {
        prepend_args = { '--style=file', '--fallback-style=LLVM' },
      },
      ---@type conform.FileFormatterConfig
      eslint = {
        args = {
          '--stdin',
          '--fix-dry-run',
          '--format=json',
          '--stdin-filename',
          '$FILENAME',
        },
        command = eslint.path,
        meta = {
          url = 'https://eslint.org/',
          description = 'An extensible linter for JavaScript and TypeScript',
        },
      },
      isort = {
        command = function()
          local _, isort_path = tooling.find_isort()
          return isort_path or 'isort'
        end,
        prepend_args = { '--profile', 'black' },
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
      python = { 'isort', 'black' },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
