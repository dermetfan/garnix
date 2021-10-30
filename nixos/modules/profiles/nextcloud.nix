{ self, config, lib, ... }:

let
  cfg = config.profiles.nextcloud;
in {
  imports = [ ../../imports/age.nix ];

  options.profiles.nextcloud.enable = lib.mkEnableOption "Nextcloud";

  config = lib.mkIf cfg.enable {
    age.secrets.nextcloud = {
      file = ../../../secrets/services/nextcloud.age;
      owner = config.users.users.nextcloud.name;
      group = config.users.users.nextcloud.group;
    };

    services = {
      nextcloud = {
        hostName = "nextcloud.${config.networking.domain}";
        autoUpdateApps.enable = true;
        config.adminpassFile = config.age.secrets.nextcloud.path;
      };

      nginx = {
        enable = true;
        virtualHosts.${config.services.nextcloud.hostName} = {
          enableACME = true;
          forceSSL = true;
        };
      };
    };
  };
}
