{ config, pkgs, ... }:

{
  home.packages = [ pkgs.rofi ];

  # Place your config alongside this file, e.g. ./fastfetch.jsonc
  xdg.configFile."rofi/style-1.rasi".source = ./rofi/style-1.rasi;
}
