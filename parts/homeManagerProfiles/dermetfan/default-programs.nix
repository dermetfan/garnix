{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      TERMINAL =
        if config.programs.foot.server.enable
        then "footclient"
        else "foot";
      PAGER = "less";
    };

    packages = with pkgs; [
      catalog
    ];
  };

  programs = {
    foot.enable = config.profiles.dermetfan.environments.gui.enable;
    kakoune = {
      enable = true;
      defaultEditor = true;
    };
    less.enable = true;

    yazi.enable = true;
    broot.enable = true;
    htop.enable = true;
    tmux.enable = true;
    fish.enable = true;
  };
}
