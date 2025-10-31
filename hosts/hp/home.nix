{ config, pkgs, ... }:

{
  home.username = "mrn1";
  home.homeDirectory = "/home/mrn1";
  home.stateVersion = "25.05";
  programs.zsh.initExtra = ''
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./p10k.zsh}
      '';
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
      plugins = [ "git" "z" "fzf" ];
    };

    # This is where your extra sourcing goes
  };

  home.packages = with pkgs; [
    zsh-fast-syntax-highlighting
    zsh-autosuggestions
    zsh-fzf-tab
    zsh-powerlevel10k
    fzf
  ];
}
