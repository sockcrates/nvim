local config = {
  extensions = {
    history = {
      enabled = true,
      opts = {
        -- Save all chats by default (disable to save only manually using 'sc')
        auto_save = true,
        -- Number of days after which chats are automatically deleted (0 to disable)
        expiration_days = 0,
        -- Picker interface (auto resolved to a valid picker)
        picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
        ---Optional filter function to control which chats are shown when browsing
        chat_filter = nil,    -- function(chat_data) return boolean end
        -- Customize picker keymaps (optional)
        picker_keymaps = {
          rename = { n = "r", i = "<M-r>" },
          delete = { n = "d", i = "<M-d>" },
          duplicate = { n = "<C-y>", i = "<C-y>" },
        },
        ---Automatically generate titles for new chats
        auto_generate_title = true,
        title_generation_opts = {
          ---Adapter for generating titles (defaults to current chat adapter)
          adapter = nil,               -- "copilot"
          ---Model for generating titles (defaults to current chat model)
          model = nil,                 -- "gpt-4o"
          ---Number of user prompts after which to refresh the title (0 to disable)
          refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
          ---Maximum number of times to refresh the title (default: 3)
          max_refreshes = 3,
          format_title = function(original_title)
            -- this can be a custom function that applies some custom
            -- formatting to the title.
            return original_title
          end
        },
        ---On exiting and entering neovim, loads the last chat on opening chat
        continue_last_chat = false,
        ---When chat is cleared with `gx` delete the chat from history
        delete_on_clearing_chat = false,
        ---Directory path to save the chats
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        ---Enable detailed logging for history extension
        enable_logging = false,

        -- Summary system
        summary = {
          -- Keymap to generate summary for current chat (default: "gcs")
          create_summary_keymap = "gcs",
          -- Keymap to browse summaries (default: "gbs")
          browse_summaries_keymap = "gbs",

          generation_opts = {
            adapter = nil,               -- defaults to current chat adapter
            model = nil,                 -- defaults to current chat model
            context_size = 90000,        -- max tokens that the model supports
            include_references = true,   -- include slash command content
            include_tool_outputs = true, -- include tool execution results
            system_prompt = nil,         -- custom system prompt (string or function)
            format_summary = nil,        -- custom function to format generated summary e.g to remove <think/> tags from summary
          },
        },

        -- Memory system (requires VectorCode CLI)
        memory = {
          -- Automatically index summaries when they are generated
          auto_create_memories_on_summary_generation = true,
          -- Path to the VectorCode executable
          vectorcode_exe = "vectorcode",
          -- Tool configuration
          tool_opts = {
            -- Default number of memories to retrieve
            default_num = 10
          },
          -- Enable notifications for indexing progress
          notify = true,
          -- Index all existing memories on startup
          -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
          index_on_startup = false,
        },
      }
    },
    vectorcode = {
      opts = {
        tool_group = {
          collapse = false, -- whether the individual tools should be shown in the chat
          -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
          enabled = true,
          -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
          -- if you use @vectorcode_vectorise, it'll be very handy to include
          -- `file_search` here.
          extras = {},
          file_search = {},
        },
        tool_opts = {
          ["*"] = {},
          ls = {},
          vectorise = {},
          query = {
            max_num = { chunk = -1, document = -1 },
            default_num = { chunk = 50, document = 10 },
            include_stderr = false,
            use_lsp = false,
            no_duplicate = true,
            chunk_mode = false,
            summarise = {
              enabled = false,
              adapter = nil,
              query_augmented = true,
            },
          },
          files_ls = {},
          files_rm = {},
        },
      },
    },
  },

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


return {
  'olimorris/codecompanion.nvim',
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/codecompanion-history.nvim',
    'Davidyz/VectorCode',
  },
  config = function()
    local codecompanion = require('codecompanion')
    codecompanion.setup(config)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'codecompanion',
      callback = function()
        local chat_history = codecompanion.extensions.history;

        vim.keymap.set('n', 'sc', function()
          local buffer = vim.api.nvim_get_current_buf();
          local chat = codecompanion.buf_get_chat(buffer)
          chat_history.save_chat(chat);
        end, { buffer = true, desc = 'Save Chat' })

        vim.keymap.set('n', 'gh', '<cmd>CodeCompanionHistory<CR>', { buffer = true, desc = 'Open Chat History' })

        local completion = 'codecompanion.providers.completion.cmp'
        local cmp = require('cmp')

        -- TODO: register this if models are added to config
        -- cmp.register_source("codecompanion_models", require(completion .. ".models").new(config))
        cmp.register_source("codecompanion_slash_commands", require(completion .. ".slash_commands").new(config))
        cmp.register_source("codecompanion_tools", require(completion .. ".tools").new(config))
        cmp.register_source("codecompanion_variables", require(completion .. ".variables").new())
        cmp.setup.filetype("codecompanion", {
          enabled = true,
          sources = vim.list_extend({
            { name = "codecompanion_models" },
            { name = "codecompanion_slash_commands" },
            { name = "codecompanion_tools" },
            { name = "codecompanion_variables" },
          }, cmp.get_config().sources),
        })
      end,
    })

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
