{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.effects;
in {
  options.config.profiles.effects.enable = lib.mkEnableOption "desktop effects";

  config = lib.mkIf cfg.enable {
    config.programs.compton.enable = true;

    xsession.initExtra = "compton -b";
  };
}
