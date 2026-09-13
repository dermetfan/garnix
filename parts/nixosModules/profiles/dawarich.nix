_:

{ config, lib, ... }:

let
  cfg = config.profiles.dawarich;
in {
  options.profiles.dawarich = {
    enable = lib.mkEnableOption "dawarich";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "dawarich.${config.networking.domain}";
    };

    oidcIssuer = lib.mkOption {
      type = lib.types.str;
    };

    oidcProviderName = lib.mkOption {
      type = lib.types.str;
      default = "Authelia";
    };
  };

  config = lib.mkIf cfg.enable {
    profiles.dawarich.oidcIssuer = lib.mkOptionDefault "https://${config.services.authelia.nginx.virtualHosts.default.host}";

    age.secrets.dawarich-env.file = ../../../secrets/services/dawarich.env.age;

    services = {
      dawarich = {
        enable = true;
        localDomain = cfg.domain;
        environment = {
          OIDC_CLIENT_ID = "AjHcARFIikt6FyZ4Ec6tDbXG3Dj7q4til5ZYcG3cW0ALXndRbz2R1.wdeSpR4ZZrR8ZPomKjvYzFXjgj0Br5qGJF.GGA_jcJrf3~";
          OIDC_ISSUER = cfg.oidcIssuer;
          OIDC_REDIRECT_URI = "https://${config.services.dawarich.localDomain}/users/auth/openid_connect/callback";
          OIDC_PROVIDER_NAME = cfg.oidcProviderName;
          ALLOW_EMAIL_PASSWORD_LOGIN = lib.boolToString false;
        };
        extraEnvFiles = lib.singleton config.age.secrets.dawarich-env.path;
      };

      nginx.virtualHosts.${config.services.dawarich.localDomain} = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };
}
