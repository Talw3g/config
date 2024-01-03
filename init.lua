local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn
-- ensure that packer is installed
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
    execute 'packadd packer.nvim'
end
vim.cmd('packadd packer.nvim')
local packer = require'packer'
local util = require'packer.util'
packer.init({
  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

packer.startup(function()
  local use = use

  use 'wbthomason/packer.nvim'

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'nvimtools/none-ls.nvim'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
  use 'WhoIsSethDaniel/mason-tool-installer.nvim'

  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  })

  use 'simrat39/rust-tools.nvim'

  use 'sainnhe/gruvbox-material'
  use 'rust-lang/rust.vim'

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  -- Needs ripgrep installed : sudo apt install ripgrep
  use {"nvim-telescope/telescope.nvim", tag = "0.1.2",
    requires = {{'nvim-lua/plenary.nvim'}}
  }

  use 'nvim-lualine/lualine.nvim'

  use {
    'j-hui/fidget.nvim',
    tag = 'legacy',
  }

  use({
      "kylechui/nvim-surround",
      config = function()
          require("nvim-surround").setup({
              -- Configuration here, or leave empty to use defaults
          })
      end
  })

  end
)

-- global vim configurations
vim.o.ttyfast = true
vim.o.wrap = false
vim.o.incsearch = true
vim.o.mouse = ""
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.bo.autoindent = true
vim.opt.updatetime = 750

-- set leader key
vim.keymap.set('n', 'ù', '<Nop>');
vim.g.mapleader = 'ù';
vim.g.maplocalleader = 'ù';

vim.keymap.set('n', '<F2>', '<Cmd>:split<CR>')
vim.keymap.set('n', '<F3>', '<Cmd>:vertical split<CR>')
vim.keymap.set('n', '<Space>', '<Cmd>:tab new<CR>')
vim.keymap.set({'n', 'i'}, '<C-Left>', '<Cmd>:tabp<CR>')
vim.keymap.set({'n', 'i'}, '<C-Right>', '<Cmd>:tabn<CR>')
vim.keymap.set('n', '<C-Up>', '<Cmd>:m .-2<CR>==')
vim.keymap.set('n', '<C-Down>', '<Cmd>:m .+1<CR>==')
vim.keymap.set('i', '<C-Up>', '<Cmd>:m .-2<CR>')
vim.keymap.set('i', '<C-Down>', '<Cmd>:m .+1<CR>')
vim.keymap.set({'n', 'i'}, '<A-Up>', '<Cmd>:wincmd k<CR>')
vim.keymap.set({'n', 'i'}, '<A-Down>', '<Cmd>:wincmd j<CR>')
vim.keymap.set({'n', 'i'}, '<A-Right>', '<Cmd>:wincmd l<CR>')
vim.keymap.set({'n', 'i'}, '<A-Left>', '<Cmd>:wincmd h<CR>')


vim.o.wildmode = "list:longest"

local servers = {
  pylsp = {
    pylsp = {
        plugins = {
          pycodestyle = {
            ignore = {'E266', 'W503', 'W504'},
            maxLineLength = 100
          },
          autopep8 = {
            enabled = false,
          },
          yapf = {
            enabled = false,
            column_limit = 100,
          },
        }
    }
  },
}
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Mason Setup
require("mason").setup({
    ui = {
        icons = {
        }
    }
})
-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
	automatic_installation = true,
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      settings = servers[server_name],
    }
  end,
}

require('mason-tool-installer').setup({
    ensure_installed = {
        'prettierd',
        'black',
        'isort',
    },
})
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.prettierd,
  }
})

-- status line
require('lualine').setup({
    options = {
        theme = 'gruvbox',
    },
    inactive_sections = {
        lualine_c = { "%{expand('%:p:h:t')}/%t" },
    },
    sections = {
        lualine_c = { "%{expand('%:p:h:t')}/%t" },
        lualine_x = { 'g:my_hex_infos' },
    },
})

-- rust-tools
local rt = require("rust-tools")
rt.setup({
    tools = {
        inlay_hints = {
            auto = true,
        },
    },
    server = {
        on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<Leader>z", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
        end,
    }
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- LSP Diagnostics Options Setup
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- use TAB to go to next LSP diagnostic
vim.keymap.set("n", "<Tab>", vim.diagnostic.goto_next, {})
vim.keymap.set("n", "<S-Tab>", vim.diagnostic.goto_prev, {})
-- use F4 to go to definition
--vim.keymap.set("n", "<F4>", vim.lsp.buf.declaration, {})


vim.g.rustfmt_autosave = 1


-- toggle term
require('toggleterm').setup({
    open_mapping = [[²]],
    direction = 'float',
    float_opts = {
        border = 'curved',
    },
})

-- telescope
require('telescope').setup({

})
function my_git_files()
    local x = vim.fn.expand('%:p:h')
    return require('telescope.builtin').git_files({cwd=x})
end
vim.keymap.set("n", "<C-p>", my_git_files, {})
function my_find_files()
    return require('telescope.builtin').find_files({cwd="~"})
end
-- XXX C-o conflict with go back in jump list
--vim.keymap.set("n", "<C-o>", my_find_files, {})

vim.keymap.set("n", "<C-l>", require('telescope.builtin').diagnostics, {})

-- fidget
require('fidget').setup({})

-- 
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

--require('monokai').setup { palette = require('monokai').soda }
vim.cmd([[:colorscheme gruvbox-material ]])

