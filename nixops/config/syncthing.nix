{ config, lib, ... }:

{
  services.syncthing.openDefaultPorts = true;

  networking.firewall.allowedTCPPorts =
    lib.optional (config.services.syncthing.enable && config.services.syncthing.openDefaultPorts) 8384; # web GUI
}
