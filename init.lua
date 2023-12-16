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
-- startup and add configure plugins
packer.startup(function()
  local use = use

  use 'wbthomason/packer.nvim'

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  use 'neovim/nvim-lspconfig'
  use 'simrat39/rust-tools.nvim'

  use 'sainnhe/gruvbox-material'
  use 'rust-lang/rust.vim'

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  use {"nvim-telescope/telescope.nvim", tag = "0.1.2",
    requires = {{'nvim-lua/plenary.nvim'}}
  }

  use 'nvim-lualine/lualine.nvim'

  use {
    'j-hui/fidget.nvim',
    tag = 'legacy',
  }

  end
)

-- global vim configurations
vim.o.ttyfast = true
vim.o.wrap = false
vim.o.incsearch = true
vim.o.mouse = ""
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.bo.autoindent = true
vim.opt.updatetime = 750

-- set leader key
vim.keymap.set('n', 'ù', '<Nop>');
vim.g.mapleader = 'ù';
vim.g.maplocalleader = 'ù';

vim.keymap.set('n', '<F2>', '<Cmd>:split<CR>',{noremap = true})
vim.keymap.set('n', '<F3>', '<Cmd>:vertical split<CR>',{noremap = true})
vim.keymap.set('n', '<Space>', '<Cmd>:tab new<CR>',{noremap = true})
vim.keymap.set('n', '<C-Left>', '<Cmd>:tabp<CR>',{noremap = true})
vim.keymap.set('n', '<C-Right>', '<Cmd>:tabn<CR>',{noremap = true})
vim.keymap.set('n', '<C-Up>', '<Cmd>:m .-2<CR>==',{noremap = true})
vim.keymap.set('n', '<C-Down>', '<Cmd>:m .+1<CR>==',{noremap = true})
vim.keymap.set('i', '<C-Up>', '<Cmd>:m .-2<CR>',{noremap = true})
vim.keymap.set('i', '<C-Down>', '<Cmd>:m .+1<CR>',{noremap = true})


vim.o.wildmode = "list:longest"

-- Mason Setup
require("mason").setup({
    ui = {
        icons = {
        }
    }
})
require("mason-lspconfig").setup()

-- homemade show hex / bin
vim.api.nvim_create_autocmd({"CursorMoved"}, {
    callback = function(ev)
        local function matchstr(...)
            local ok,ret = pcall(fn.matchstr, ...)
            return ok and ret or ""
        end
        local column = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        
        local left = matchstr(line:sub(1, column+1), [[[0-9a-fx]*$]])
        local right = matchstr(line:sub(column+1), [[^[0-9a-fx]*]]):sub(2)
        
        local cword = left .. right
       
        v = tonumber(cword)
        if v == nil then
            vim.g.my_hex_infos = ''
        else
            if v <= 0xffff then
                hex2bin = {
                    ['0'] = '0000', ['1'] = '0001', ['2'] = '0010', ['3'] = '0011',
                    ['4'] = '0100', ['5'] = '0101', ['6'] = '0110', ['7'] = '0111',
                    ['8'] = '1000', ['9'] = '1001', ['a'] = '1010', ['b'] = '1011',
                    ['c'] = '1100', ['d'] = '1101', ['e'] = '1110', ['f'] = '1111',
                }
                local hex = string.format("%x", v);
                local bin = "";
                for i = 1, #hex do
                    local c = hex:sub(i,i)
                    if bin == '' then
                        bin = hex2bin[c]
                    else
                        bin = bin .. '_' .. hex2bin[c]
                    end
                end

                vim.g.my_hex_infos = string.format("%d 0x%s %s", v, hex, bin)
            else 
                vim.g.my_hex_infos = string.format("%d 0x%x", v, v)
            end
        end
        -- 0x42 45 129321 02193210 0x0000
    end
})

-- 123213

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
-- use F4 to go to definition
vim.keymap.set("n", "<F4>", vim.lsp.buf.declaration, {})


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
