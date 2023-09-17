_:

{ config, lib, ... }:

let
  cfg = config.profiles.ntfy-sh;
in {
  options.profiles.ntfy-sh = with lib; {
    enable = mkEnableOption "ntfy-sh";

    domain = mkOption {
      type = types.str;
      default = "ntfy.${config.networking.domain}";
    };
  };

  config = lib.mkIf cfg.enable (let
    CacheDirectory = "ntfy-sh";
  in {
    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          listen-http = lib.mkDefault ":2586";
          base-url = "https://${cfg.domain}";
          upstream-base-url = "https://ntfy.sh";
          auth-default-access = "deny-all";
          attachment-cache-dir = "/var/cache/${CacheDirectory}/attachments";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = let
          split = lib.splitString ":" config.services.ntfy-sh.settings.listen-http;
          addr = lib.pipe split [
            builtins.head
            (addr: if addr == "" || addr == "0.0.0.0" then "127.0.0.1" else addr)
          ];
          port = builtins.elemAt split 1;
        in assert (builtins.length split == 2); "http://${addr}:${port}";
      };
    };

    systemd.services.ntfy-sh.serviceConfig = { inherit CacheDirectory; };
  });
}
