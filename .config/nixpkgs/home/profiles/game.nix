{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    pkgs."2048-in-terminal"
    fortune
    lolcat
    ponysay
    rogue
    sl
  ] ++ lib.optionals config.xsession.enable [
    cool-old-term
    minecraft
    teamspeak_client
  ];
}
