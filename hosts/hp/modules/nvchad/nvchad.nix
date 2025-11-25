{ inputs, config, pkgs, ... }: {
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
require("nvchad.configs.lspconfig").defaults()
-- Will use system clipboard
vim.opt.clipboard = "unnamedplus"
-- These two lines will fix space issues when pasting
vim.opt.autoindent = false
vim.opt.smartindent = false

local servers = { "html", "cssls", "nixd" }
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
      'andweeb/presence.nvim',
      lazy = false,
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
        "html", "css", "bash",
   		},
   	},
   },
}

    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server-nodejs
      emmet-language-server
      nixd
      (python3.withPackages(ps: with ps; [
        python-lsp-server
        flake8
      ]))
    ];
    hm-activation = true;
    backup = false;
  };
}
