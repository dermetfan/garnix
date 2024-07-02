{ config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.game.enable.default = false;

  config = {
    home.packages = with pkgs; [
      fortune
      lolcat
      mcrcon
      ponysay
      rogue
      sl
    ] ++ lib.optionals config.profiles.dermetfan.environments.gui.enable [
      kobodeluxe
      cool-retro-term
      teamspeak_client
    ];
  };
}
