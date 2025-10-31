{ config, pkgs, ... }:

{
  home.username = "mrn1";
  home.homeDirectory = "/home/mrn1";
  home.stateVersion = "25.05";
  programs.zsh = {
    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [ "zsh-autosuggestions" "fast-syntax-highlighting" "fzf-tab" "zsh-you-should-use" ];
      theme = "robbyrussell";
    };
  };

  home.packages = with pkgs; [
  bat
  ];
}

