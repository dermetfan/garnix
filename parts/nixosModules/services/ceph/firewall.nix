_:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph;
in {
  options.services.ceph = with lib; {
    mon.openFirewall = mkEnableOption "open ports for Ceph MONs";
    mgr.openFirewall = mkEnableOption "open ports for Ceph MGRs";
    mds.openFirewall = mkEnableOption "open ports for Ceph MDSs";
    osd.openFirewall = mkEnableOption "open ports for Ceph OSDs";
  };

  config.networking.firewall = {
    allowedTCPPorts = lib.optionals cfg.mon.openFirewall [ 3300 6789 ];
    allowedTCPPortRanges = lib.optionals (
      cfg.mgr.openFirewall ||
      cfg.mds.openFirewall ||
      cfg.osd.openFirewall
    ) [ { from = 6800; to = 7300; } ];
  };
}
