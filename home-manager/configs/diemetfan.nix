{ self, nixosConfig, config, lib, ... }:

{
  imports = [ self.outputs.homeManagerModule ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "geany";
    PAGER = "less";
    LESS = "-RiW -#.05 -n4 -z-3";
  };

  programs = {
    alacritty.enable = true;
    ranger.enable = true;
    broot.enable = true;
    htop.enable = true;
    geany.enable = true;
    kakoune.enable = true;
    tmux.enable = true;
    fish.enable = true;
    tkremind.enable = true;
  };
}
