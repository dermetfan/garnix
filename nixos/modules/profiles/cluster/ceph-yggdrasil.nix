{ config, lib, ... }:

let
  cfg = config.profiles.cluster.ceph;
in {
  options.profiles.cluster.ceph.yggdrasil = lib.mkEnableOption "communication via Yggdrasil";

  config = lib.mkIf cfg.yggdrasil {
    profiles.yggdrasil.enable = true;

    # XXX Cannot use `services.ceph.mon.extraConfig` due to its type. Fix upstream?
    environment.etc."ceph/ceph.conf".text = lib.generators.toINI {} (
      lib.genAttrs
        (map (daemon: "mon.${daemon}") config.services.ceph.mon.daemons)
        (daemon: { "public addr" = "[${config.profiles.yggdrasil.ip}]"; })
    );

    services.ceph = {
      global.monHost = lib.concatMapStringsSep ","
        (host: "[${host.config.profiles.yggdrasil.ip}]")
        cfg.monInitialHosts;

      extraConfig."ms bind ipv6" = builtins.toJSON true;
    };
  };
}
