{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];

  programs.nvchad = {
    enable = true;
    chadrcConfig = ''
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
    backup = true;
  };
}
