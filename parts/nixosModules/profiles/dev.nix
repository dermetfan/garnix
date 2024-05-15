_:

{ config, lib, pkgs, ... }:

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

    environment.systemPackages = with pkgs; [
      man-pages
    ];

    documentation = {
      dev.enable = true;
      man.generateCaches = true;
    };

    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
  };
}
