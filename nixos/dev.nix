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
        externalInterface = "enp3s0"; # TODO make configurable
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
