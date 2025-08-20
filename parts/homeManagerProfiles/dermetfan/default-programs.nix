{ pkgs, ... }:

{
  home = {
    sessionVariables = {
      TERMINAL = "alacritty";
      PAGER = "less";
    };

    packages = with pkgs; [
      catalog
    ];
  };

  programs = {
    alacritty.enable = true;
    kakoune = {
      enable = true;
      defaultEditor = true;
    };
    less.enable = true;

    ranger.enable = true;
    broot.enable = true;
    htop.enable = true;
    tmux.enable = true;
    fish.enable = true;
  };
}
