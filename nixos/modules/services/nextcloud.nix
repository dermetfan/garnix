{ self, config, lib, ... }:

let
  cfg = config.services.nextcloud;
in {
  imports = [ ../../imports/age.nix ];

  config = lib.mkIf cfg.enable {
    age.secrets.nextcloud = {
      file = ../../../secrets/nextcloud.age;
      owner = config.users.users.nextcloud.name;
      group = config.users.users.nextcloud.group;
    };

    services = {
      nextcloud = {
        hostName = "nextcloud.${config.networking.domain}";
        autoUpdateApps.enable = true;
        config = {
          adminuser = "dermetfan";
          adminpassFile = config.age.secrets.nextcloud.path;
        };
      };

      nginx = {
        enable = true;
        virtualHosts.${cfg.hostName} = {
          enableACME = true;
          forceSSL = true;
        };
      };
    };
  };
}
