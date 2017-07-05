{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    abcde
    mplayer
    mpv
  ] ++ (if config.xsession.enable then [
    vlc
  ] else []);
}
