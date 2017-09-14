{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.effects;
in {
  options.config.profiles.effects.enable = lib.mkEnableOption "desktop effects";

  config = lib.mkIf cfg.enable {
    services.compton.enable = true;
  };
}
