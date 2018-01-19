{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.game;
in {
  options.config.profiles.game.enable = lib.mkEnableOption "games";

  config = lib.mkIf cfg.enable {
    config.programs.minecraft.enable = config.xsession.enable;

    home.packages = with pkgs; [
      pkgs."2048-in-terminal"
      fortune
      lolcat
      mcrcon
      ponysay
      rogue
      sl
    ] ++ lib.optionals config.xsession.enable [
      kobodeluxe
      cool-old-term
      teamspeak_client
    ];
  };
}
