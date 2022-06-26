{ config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.game.enable.default = false;

  config = {
    programs.minecraft.enable = config.profiles.dermetfan.environments.gui.enable;

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
