{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.game;
in {
  options.profiles.game.enable = lib.mkEnableOption "games";

  config = lib.mkIf cfg.enable {
    programs.minecraft.enable = config.profiles.gui.enable;

    home.packages = with pkgs; [
      fortune
      lolcat
      mcrcon
      ponysay
      rogue
      sl
    ] ++ lib.optionals config.profiles.gui.enable [
      kobodeluxe
      cool-old-term
      teamspeak_client
    ];
  };
}
