{ config, pkgs, ... }:

{

  # Place your config alongside this file, e.g. ./fastfetch.jsonc
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
