{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    abcde
    mplayer
    mpv
  ] ++ lib.optionals config.xsession.enable [
    vlc
  ];
}
