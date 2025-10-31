{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  programs.nvchad = {
    enable = true;
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
    xdg.configFile."nvim/lua/custom/chadrc.lua".text = ''
      local M = {}
      M.ui = {
        theme = "chadracula-evondev", -- or "onedark", "gruvbox", "tokyonight", etc.
      }
      return M
    '';
  };
}
