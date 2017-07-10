{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; lib.optionals config.xsession.enable [
    audacious
    chromium
    feh
    geany
    htop
    lilyterm
    pass
    qalculate-gtk
    rss-glx
    smplayer
    vivaldi
    xarchiver
    xfe
    zathura
  ];
}
