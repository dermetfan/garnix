_:

{ config, lib, ... }:

let
  cfg = config.profiles.ntfy-sh;
in {
  options.profiles.ntfy-sh = {
    enable = lib.mkEnableOption "ntfy-sh";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ntfy.${config.networking.domain}";
    };
  };

  config = let
    StateDirectory = "ntfy-sh";
    RuntimeDirectory = StateDirectory;
  in lib.mkIf cfg.enable {
    age.secrets.ntfy-sh = {
      file = ../../../secrets/services/ntfy-sh.age;
      owner = config.services.ntfy-sh.user;
      inherit (config.services.ntfy-sh) group;
    };

    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          listen-http = "";
          listen-unix = "/run/${RuntimeDirectory}/ntfy-sh.sock";
          listen-unix-mode = 0660;
          behind-proxy = true;
          base-url = "https://${cfg.domain}";
          upstream-base-url = "https://ntfy.sh";
          enable-login = true;
          require-login = true;
          auth-default-access = "deny-all";
          auth-access = [
            "dermetfan:*:read-write"
            "diemetfan:diemetfan:read-write"
          ];
          web-push-file = "/var/lib/${StateDirectory}/webpush.db";
          web-push-email-address = "serverkorken@gmail.com";
        };
        environmentFile = config.age.secrets.ntfy-sh.path;
      };

      nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://unix:${config.services.ntfy-sh.settings.listen-unix}";
      };
    };

    systemd.services = {
      ntfy-sh.serviceConfig = {
        inherit RuntimeDirectory;
      };

      nginx.serviceConfig.SupplementaryGroups = [ config.services.ntfy-sh.group ];
    };
  };
}
