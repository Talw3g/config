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
  
  use 'averms/black-nvim'

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

-- Mason Setup
require("mason").setup({
    ui = {
        icons = {
        }
    }
})
require("mason-lspconfig").setup {
    ensure_installed = {
      "pylsp",
    },
    automatic_installation = true,
}

-- nvim LSP config
require'lspconfig'.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        black = {
          line_length = 100
        }
      }
    }
  }
}

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
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
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

