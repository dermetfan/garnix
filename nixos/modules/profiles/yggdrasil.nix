{ config, lib, ... }:

let
  cfg = config.profiles.yggdrasil;

  secret = file:
    ../../../secrets/hosts/${config.networking.hostName}/yggdrasil/${file};
in {
  imports = [ ../../imports/age.nix ];

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
    age.secrets."yggdrasil.conf".file = secret "key.conf.age";

    services.yggdrasil = {
      enable = true;
      configFile = config.age.secrets."yggdrasil.conf".path;
      config = {
        Listen = [ "tcp://[::]:${toString cfg.port}" ];
        PublicKey = lib.fileContents (secret "key.pub");
      };
    };

    networking = {
      hosts.${cfg.ip} = lib.mkDefault [
        config.networking.fqdn
        config.networking.hostName
      ];

      firewall.allowedTCPPorts = [ cfg.port ];
    };
  };
}
