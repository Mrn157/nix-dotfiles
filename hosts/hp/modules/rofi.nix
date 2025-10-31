{ config, pkgs, ... }:

{
  home.packages = [ pkgs.rofi ];

  # Place your config alongside this file, e.g. ./fastfetch.jsonc
  xdg.configFile."rofi/launchers/type-2/style-1.rasi".source = ./rofi/launchers/type-2/style-2.rasi;
}
