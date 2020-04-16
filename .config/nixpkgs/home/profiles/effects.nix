{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.effects;
in {
  options.profiles.effects.enable = lib.mkEnableOption "desktop effects";

  config = lib.mkIf cfg.enable {
    services.picom.enable = config.xsession.enable;
  };
}
