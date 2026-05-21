{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.hardening;
in {
  options.profiles.hardening = {
    enable = lib.mkEnableOption "hardening";

    breakHibernation = lib.mkEnableOption "options that break hibernation";
  };

  config = lib.mkIf cfg.enable {
    security = {
      protectKernelImage = lib.mkIf cfg.breakHibernation true;

      sudo.execWheelOnly = true;
    };

    nix.settings.allowed-users = [ "@${config.users.groups.wheel.name}" ];
  };
}
