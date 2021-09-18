{ config, lib, ... }:

let
  cfg = config.profiles.dev;
in {
  options.profiles.dev.enable = lib.mkEnableOption "dev settings";

  config = lib.mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        internalInterfaces = [
          "ve-+" # nixos-containers
        ];
        # externalInterface has to be set in user's config
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
