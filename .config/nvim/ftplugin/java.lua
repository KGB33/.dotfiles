-- Compile & add errors to quick fix list
vim.cmd[[compiler javac]]

function compile()
	vim.cmd("make %")
	require"telescope.builtin".quickfix()
end

local vimp = require('vimp')

vimp.nnoremap('<leader>m', compile)

-- Override default telescope code action mapping
vim.api.nvim_set_keymap("n", "<Leader>a", ':lua vim.lsp.buf.code_action()<Enter>', {noremap=false})

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local jdtls_path = '/home/kgb33/.config/nvim/.jdtls/'
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    -- 💀
    'java', -- or '/path/to/java11_or_newer/bin/java'
            -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    -- 💀
    '-jar', jdtls_path .. 'plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',

    -- 💀
    '-configuration', jdtls_path .. '/config_linux',


    -- 💀
    -- See `data directory configuration` section in the README
    '-data',  '/home/kgb33/.cache/jdtls/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require('jdtls.setup').find_root({'mvnw', 'gradlew', '.git', }),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
    }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
	  bundles = {
	  };
  },
  on_attach = function(client, buffer)
	  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
	  require('jdtls.dap').setup_dap_main_class_configs() 
	  require('jdtls.setup').add_commands() -- call after dap
  end,
}


-- This bundles definition is the same as in the previous section (java-debug installation)
local bundles = {
  vim.fn.glob("path/to/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"),
};

vim.list_extend(bundles, vim.split(vim.fn.glob("/home/kgb33/.config/nvim/vscode-java-test/server/*.jar"), "\n"))
config['init_options'] = {
  bundles = bundles;
}


-- Standard java formatting seems to want two spaces
-- Probably due to the long names.
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- UI
local finders = require'telescope.finders'
local sorters = require'telescope.sorters'
local actions = require'telescope.actions'
local pickers = require'telescope.pickers'
require('jdtls.ui').pick_one_async = function(items, prompt, label_fn, cb)
  local opts = {}
  pickers.new(opts, {
    prompt_title = prompt,
    finder    = finders.new_table {
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = label_fn(entry),
          ordinal = label_fn(entry),
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      actions.goto_file_selection_edit:replace(function()
        local selection = actions.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)

        cb(selection.value)
      end)

      return true
    end,
  }):find()
end

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
