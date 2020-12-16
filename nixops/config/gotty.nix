{ config, lib, pkgs, ... }:

let
  cfg = config.services.gotty;
in {
  options.services.gotty.enable = lib.mkEnableOption "gotty";

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${domain}."/gotty/" = {
      proxyPass = http://127.0.0.1:4201/;
      proxyWebsockets = true;
    };

    systemd.services.gotty = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gotty ];
      script = "gotty --port 4201 --permit-write /run/current-system/sw/bin/login";
      environment = {
        GOTTY_PORT = "4201";
        GOTTY_PERMIT_WRITE = "1";
      };
    };
  };
}
