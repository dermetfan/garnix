_:

{ config, lib, ... }:

{
  profiles.afraid-freedns.enable = true;

  services.openssh.settings = {
    PasswordAuthentication = lib.mkForce true;
    ChallengeResponseAuthentication = lib.mkForce true;
  };

  networking.firewall = {
    allowedTCPPorts = lib.optionals config.services.samba.enable [ 139 445 ];
    allowedUDPPorts = lib.optionals config.services.samba.enable [ 137 138 ];
  };
}
