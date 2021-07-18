{ config, lib, ... }:

lib.mkIf config.services.nginx.enable {
  services.nginx = {
    recommendedOptimisation  = true;
    recommendedProxySettings = true;
    recommendedTlsSettings   = true;
    recommendedGzipSettings  = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  passthru."nginx.virtualHosts.withSSL" = x: x // {
    enableACME = true;
    sslCertificate = ../../keys/host.crt;
    sslCertificateKey = "/run/keys/host.key";
    # run `systemctl restart acme-fixperms.service` if permissions in /var/lib/acme cause troubles
  };

  deployment.keys."host.key" = {
    keyFile = ../../keys/host.key;
    user = config.users.users.acme.name;
    group = config.users.users.nginx.group;
  };
}
