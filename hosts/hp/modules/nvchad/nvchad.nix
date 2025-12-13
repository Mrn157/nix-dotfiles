{ inputs, pkgs, ... }: {
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];

  programs.nvchad = {
    enable = true;
    chadrcConfig = /* lua */ ''
    local M = {
      base46 = {
        theme = "chadracula-evondev",
        -- hl_override = {
        --   Comment = { italic = true },
        --   ["@comment"] = { italic = true },
        -- },
      },

      nvdash = {
        load_on_startup = true,
      },

      ui = {
        transparency = true,
        tabufline = {
          lazyload = false,
        },
      },
    }

return M
    '';
    extraConfig = /* lua */ ''
-- Lazier (https://github.com/jake-stewart/lazier.nvim)
local lazierPath = vim.fn.stdpath("data") .. "/lazier/lazier.nvim"
if not (vim.uv or vim.loop).fs_stat(lazierPath) then
    local repo = "https://github.com/jake-stewart/lazier.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--branch=stable-v2", repo, lazierPath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{
            "Failed to clone lazier.nvim:\n" .. out, "Error"
        }}, true, {})
    end
end
vim.opt.runtimepath:prepend(lazierPath)

require("lazier").setup("plugins", {
    lazier = {
        before = function()
            -- function to run before the ui renders.
            -- it is faster to require parts of your config here
            -- since at this point they will be bundled and bytecode compiled.
            -- eg: require("options")
        end,

        after = function()
            -- function to run after the ui renders.
            -- eg: require("mappings")
        end,

        start_lazily = function()
            -- function which returns whether lazy.nvim
            -- should start delayed or not.
            local nonLazyLoadableExtensions = {
                zip = true,
                tar = true,
                gz = true
            }
            local fname = vim.fn.expand("%")
            return fname == ""
                or vim.fn.isdirectory(fname) == 0
                and not nonLazyLoadableExtensions
                    [vim.fn.fnamemodify(fname, ":e")]
        end,

        -- whether plugins should be included in the bytecode
        -- compiled bundle. this will make your startup slower.
        bundle_plugins = false,

        -- whether to automatically generate lazy loading config
        -- by identifying the mappings set when the plugin loads
        generate_lazy_mappings = true,

        -- automatically rebundle and compile nvim config when it changes
        -- if set to false then you will need to :LazierClear manually
        detect_changes = true,
    },

    -- your usual lazy.nvim config goes here
    -- ...
})

-- End of Lazier

require("nvchad.configs.lspconfig").defaults()

-- Relative number
vim.opt.relativenumber = true

-- Visual Block Ctrl+Q
vim.keymap.set('n', '<C-q>', '<C-v>')

-- Wilder
local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})

wilder.set_option('renderer', wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme({
    highlights = {
      border = 'Normal', -- highlight to use for the border
    },
    -- 'single', 'double', 'rounded' or 'solid'
    -- can also be a list of 8 characters, see :h wilder#popupmenu_border_theme() for more details
    border = 'rounded',
  })
))
-- Wilder

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Escape key to Ctrl \ + Ctrl N
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- Use zsh for terminal
vim.opt.shell = '/run/current-system/sw/bin/zsh'

-- Will use system clipboard
vim.opt.clipboard = "unnamedplus"
-- These two lines will fix space issues when pasting
vim.opt.autoindent = false

local servers = { "html", "cssls", "nixd", "nil_ls" }
vim.lsp.enable(servers)

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 17,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

-- https://nvchad.com/docs/recipes/ 
-- This will make nvim remeber last cursor position
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- Show Nvdash when all buffers are closed
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})
-- read :h vim.lsp.config for changing options of lsp servers 
    '';
    extraPlugins = /* lua */ ''
return {

      {
          "stevearc/conform.nvim",
           -- event = 'BufWritePre', -- uncomment for format on save
          opts = require "configs.conform",
      },

  -- These are some examples, uncomment them if you want to see them work!
       {
         "neovim/nvim-lspconfig",
          config = function()
            require "configs.lspconfig"
         end,
       },

       {
          'vyfor/cord.nvim',
          build = ':Cord update',
          lazy = false,
  -- opts = {}
       },

      {
         'gelguy/wilder.nvim',
          lazy = false,
      },

      {
        "rmagatti/auto-session",
        lazy = false,
    
       ---enables autocomplete for opts
       ---@module "auto-session"
       ---@type AutoSession.Config
       opts = {
         suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
         -- log_level = 'debug',
       },
      },


  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

   {
   	"nvim-treesitter/nvim-treesitter",
   	opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
   		ensure_installed = {
   			"vim", "lua", "vimdoc",
        "html", "css", "bash", "nix",
   		},
   	},
   },
}

    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server
      emmet-language-server
      nixd
      nil
      (python3.withPackages(ps: with ps; [
        python-lsp-server
        flake8
      ]))
    ];
    hm-activation = true;
    backup = false;
  };
}
