{ config, lib, ... }:

let
  cfg = config.config.dev;
in {
  options.config.dev.enable = lib.mkEnableOption "dev settings";

  config = lib.mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        internalInterfaces = [
          "ve-+" # nixos-containers
        ];
        externalInterface =
          config.passthru.hardware.interfaces.lan or
          config.passthru.hardware.interfaces.wlan or
          null;
      };

      networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };

    programs.adb.enable = true;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
  };
}
