{ config, lib, ... }:

let
  cfg = config.services.nginx;
in {
  services.nginx = {
    recommendedOptimisation  = true;
    recommendedProxySettings = true;
    recommendedTlsSettings   = true;
    recommendedGzipSettings  = true;
  };

  networking.firewall.allowedTCPPorts = lib.optionals cfg.enable [ 80 443 ];
}

# Run `systemctl restart acme-fixperms.service` if permissions in /var/lib/acme cause troubles.
