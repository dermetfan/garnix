{ config, lib, ... }:

{
  services = {
    nextcloud = {
      hostName = "nextcloud.${config.passthru.domain}";
      autoUpdateApps.enable = true;
      config = {
        adminuser = "dermetfan";
        adminpassFile = "/run/keys/nextcloud";
      };
    };

    nginx = lib.mkIf config.services.nextcloud.enable {
      enable = true;
      virtualHosts.${config.services.nextcloud.hostName} = config.passthru."nginx.virtualHosts.withSSL" {
        forceSSL = true;
      };
    };
  };

  deployment.keys.nextcloud = lib.mkIf config.services.nextcloud.enable {
    keyFile = ../../keys/nextcloud;
    user  = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group;
  };
}
