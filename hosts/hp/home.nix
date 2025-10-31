{ config, pkgs, ... }:

{
  home.username = "mrn1";
  home.homeDirectory = "/home/mrn1";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    neovim
    fastfetch
  ];

  home.stateVersion = "25.05";
}
