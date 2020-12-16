{ config, lib, ... }:

{
  services.nix-serve.secretKeyFile = "/run/keys/cache.sec";

  deployment.keys."cache.sec" = lib.mkIf config.services.nix-serve.enable {
    keyFile = ../../keys/cache.sec;
    user = config.users.users.nix-serve.name;
  };

  nginx.virtualHosts = lib.mkIf config.services.nix-serve.enable {
    "cache.${domain}" = config.passthru."nginx.virtualHosts.withSSL" {
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
    };
  };
}
