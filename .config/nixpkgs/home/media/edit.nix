{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kid3
  ] ++ (if config.xsession.enable then [
    audacity
    lmms
    gimp
    keymon
    obs-studio
  ] else []);
}
