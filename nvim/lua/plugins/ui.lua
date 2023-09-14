-- UI-related plugins.

local Plug = require('utils.plug_utils').Plug
local PlugConfig = require('utils.plug_utils').PlugConfig
local UpdateRemotePlugins = require('utils.plug_utils').UpdateRemotePlugins

local has_py3 = function(p) return require('config.pynvim')() end

return {
  -- Basic UI Components
  Plug 'MunifTanjim/nui.nvim' { lazy = true };  -- see config/ui.lua
  Plug 'stevearc/dressing.nvim' { event = 'VeryLazy', config = require 'config.ui'.setup_dressing };
  Plug 'skywind3000/vim-quickui' {
    event = 'VeryLazy',
    init = require('config.ui').init_quickui,
    config = require('config.ui').setup_quickui,
  };

  -- FZF & Grep
  Plug 'junegunn/fzf' {
    name = 'fzf',
    dir = '~/.fzf',
    build = './install --all --no-update-rc',
    cmd = 'FZF', func = 'fzf#*',
  };
  Plug 'junegunn/fzf.vim' {    -- deprecated in favor of fzf-lua
    event = 'CmdlineEnter',
    func = 'fzf#vim#*', lazy = true,
    dependencies = { 'fzf' },
  };
  Plug 'ibhagwan/fzf-lua' {
    event = 'VeryLazy',
    config = require('config.fzf').setup,
  };
  Plug 'wookayin/fzf-ripgrep.vim' {
    cmd = { 'RgFzf', 'Rg', 'RgDefFzf' },
    func = 'fzf#vim#ripgrep#*', lazy = true,
  };
  Plug 'rking/ag.vim' { func = 'ag#*', lazy = true };

  -- Telescope (config/telescope.lua)
  Plug 'nvim-telescope/telescope.nvim' {
    branch = vim.fn.has('nvim-0.9.0') > 0 and 'master' or '0.1.x', -- nvim 0.8.0 compat
    name = vim.fn.has('nvim-0.9.0') > 0 and 'telescope.nvim' or 'telescope.nvim.legacy',
    event = 'CmdlineEnter',
    config = function()
      -- as a script, not as a module yet
      require 'config/telescope'
    end,
  };

  -- Terminal
  Plug 'voldikss/vim-floaterm' { event = 'CmdlineEnter' };

  -- Wildmenu
  Plug 'wookayin/wilder.nvim' {
    dependencies = {'romgrk/fzy-lua-native'},
    cond = has_py3,
    build = UpdateRemotePlugins,
    event = 'CmdlineEnter',
    func = 'wilder#*',
  };

  -- Explorer
  Plug 'nvim-neo-tree/neo-tree.nvim' {
    branch = 'main',
    event = (function()
      -- If any of the startup argument is a directory,
      -- we don't lazy-load neotree so it can hijack netrw.
      if vim.tbl_contains(vim.tbl_map(vim.fn.isdirectory, vim.fn.argv()), 1) then return nil
      else return 'VeryLazy' end
    end)(),
    init = function() vim.g.neo_tree_remove_legacy_commands = 1; end,
    config = require('config.neotree').setup_neotree,
  };

  Plug 'scrooloose/nerdtree' {
    cmd = { 'NERDTree', 'NERDTreeToggle', 'NERDTreeTabsToggle' },
    keys = '<Plug>NERDTreeTabsToggle',
    dependencies = {
      Plug 'jistr/vim-nerdtree-tabs';
      Plug 'Xuyuanp/nerdtree-git-plugin';
    },
  };

  -- Navigation
  Plug 'vim-voom/VOoM' { cmd = { 'Voom', 'VoomToggle' } };
  Plug 'majutsushi/tagbar' { cmd = { 'Tagbar', 'TagbarOpen', 'TagbarToggle' } };

  -- Quickfix
  Plug 'kevinhwang91/nvim-bqf' { ft = 'qf', config = require('config.quickfix').setup_bqf };

  -- Marks and Signs
  Plug 'kshenoy/vim-signature' {
    event = 'VeryLazy',
    config = function()
      -- hlgroups are registered on VimEnter, so need to setup after lazy loading
      pcall(vim.fn['signature#utils#SetupHighlightGroups'])
    end
  };
  Plug 'vim-scripts/errormarker.vim' { event = 'VeryLazy' };

  -- Etc
  Plug 'NvChad/nvim-colorizer.lua' { lazy = true };
}
