{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    htop
    pass
  ] ++ (lib.optionals config.xsession.enable [
    audacious
    chromium
    feh
    geany
    lilyterm
    qalculate-gtk
    rss-glx
    smplayer
    vivaldi
    xarchiver
    xfe
    zathura
  ]);
}
