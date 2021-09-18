{ self, config, lib, ... }:

let
  cfg = config.services.nix-serve;
in {
  imports = [ ../../imports/age.nix ];

  options.services.nix-serve.domain = with lib; mkOption {
    type = types.str;
    default = "cache.${config.networking.domain}";
  };

  config = lib.mkIf cfg.enable {
    age.secrets."cache.sec" = {
      file = ../../../secrets/cache.sec.age;
      owner = config.users.users.nix-serve.name;
      group = config.users.users.nix-serve.group;
    };

    services = {
      nix-serve.secretKeyFile = config.age.secrets."cache.sec".path;

      nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
