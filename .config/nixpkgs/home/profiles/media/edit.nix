{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kid3
  ] ++ lib.optionals config.xsession.enable [
    audacity
    lmms
    gimp
    keymon
    obs-studio
  ];
}
