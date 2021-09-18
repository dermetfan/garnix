{ config, lib, ... }:

let
  cfg = config.services.syncthing;
in {
  services.syncthing.openDefaultPorts = true;

  networking.firewall.allowedTCPPorts =
    lib.optional (cfg.enable && cfg.openDefaultPorts) 8384; # web GUI
}
