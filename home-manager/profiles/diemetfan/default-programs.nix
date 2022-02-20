{ self, ... }:

{
  imports = [ self.outputs.homeManagerProfiles.dermetfan ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "geany";
    PAGER = "less";
  };

  programs = {
    alacritty.enable = true;
    geany.enable = true;
    less.enable = true;

    ranger.enable = true;
    broot.enable = true;
    htop.enable = true;
    kakoune.enable = true;
    tmux.enable = true;
    fish.enable = true;
    tkremind.enable = true;
  };
}
