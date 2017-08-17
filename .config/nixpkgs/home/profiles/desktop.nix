{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    gnupg
    htop
    pass
    unrar
    unzip
    zip
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
