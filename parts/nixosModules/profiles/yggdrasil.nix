{ inputs, ... }:

{ config, lib, ... }:

let
  cfg = config.profiles.yggdrasil;

  secret = file:
    ../../../secrets/hosts/${config.networking.hostName}/yggdrasil/${file};
in {
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  options.profiles.yggdrasil = with lib; {
    enable = mkEnableOption "yggdrasil node";

    port = mkOption {
      type = types.port;
      default = 16384;
      description = "Arbitrary port to open in the firewall for peers.";
    };

    ip = mkOption {
      readOnly = true;
      type = types.str;
      default = fileContents (secret "ip");
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."yggdrasil.conf" = {
      file = secret "key.conf.age";
      mode = "440";
      group = config.users.groups.yggdrasil-secrets.name;
    };

    users.groups.yggdrasil-secrets = {};

    services.yggdrasil = {
      enable = true;
      group = config.users.groups.wheel.name;
      configFile = config.age.secrets."yggdrasil.conf".path;
      settings = {
        Listen = [ "tls://[::]:${toString cfg.port}" ];
        PublicKey = lib.fileContents (secret "key.pub");
      };
    };

    systemd.services.yggdrasil.serviceConfig.SupplementaryGroups = [ config.users.groups.yggdrasil-secrets.name ];

    networking = {
      hosts.${cfg.ip} = lib.mkDefault [
        config.networking.fqdn
        config.networking.hostName
      ];

      firewall.allowedTCPPorts = [ cfg.port ];
    };
  };
}
