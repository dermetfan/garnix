{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.mgr.dashboard;
in {
  options.services.ceph.mgr.dashboard = with lib; {
    enable = mkEnableOption "the dashboard";

    port = mkOption {
      type = with types; attrsOf port;
      default = lib.genAttrs config.services.ceph.mgr.daemons (mgr: 6780);
    };

    virtualHost = {
      enable = mkEnableOption "nginx virtual host for the dashboard" // {
        default = cfg.enable;
      };

      domain = mkOption {
        type = types.str;
        default = "ceph.${config.networking.domain}";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ceph-mgr-dashboard-setup = rec {
      wantedBy = [ "ceph-mgr.target" ];
      before = wantedBy;
      path = with pkgs; [ ceph ];
      script = ''
        # FIXME this only works if a client.admin key is present
        ceph mgr module enable dashboard
      '' + lib.concatMapStrings (mgr: ''
        ceph config set mgr mgr/dashboard/${mgr}/server_port ${toString cfg.port.${mgr}}
      '') (builtins.attrNames cfg.port);
      serviceConfig.Type = "oneshot";
    };

    services.nginx = lib.mkIf cfg.virtualHost.enable {
      enable = true;
      virtualHosts.${cfg.virtualHost.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = let
          ip =
            if config.networking.enableIPv6
            then "[::]"
            else "127.0.0.1";
          port = let
            ports = builtins.attrValues cfg.port;
          in lib.traceIf (builtins.length ports > 1) ''
            There is more than one Ceph dashboard on this host.
            ${cfg.virtualHost.domain} will only proxy the first!
          '' (lib.head ports);
        in "http://${ip}:${toString port}";
      };
    };
  };
}
