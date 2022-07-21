_:

{ config, lib, ... }:

{
  profiles.afraid-freedns.enable = true;

  services.openssh = {
    passwordAuthentication = lib.mkForce true;
    challengeResponseAuthentication = lib.mkForce true;
  };

  networking.firewall = {
    allowedTCPPorts = lib.optionals config.services.samba.enable [ 139 445 ];
    allowedUDPPorts = lib.optionals config.services.samba.enable [ 137 138 ];
  };
}
