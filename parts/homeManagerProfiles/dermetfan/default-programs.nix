{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      TERMINAL =
        if config.xsession.enable
        then "alacritty"
        else if config.programs.foot.server.enable
        then "footclient"
        else "foot";
      PAGER = "less";
    };

    packages = with pkgs; [
      catalog
    ];
  };

  programs = {
    alacritty.enable = config.xsession.enable;
    foot.enable = !config.xsession.enable;
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
