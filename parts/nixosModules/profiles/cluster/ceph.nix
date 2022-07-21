_:

{ options, config, lib, ... }:

let
  cfg = config.profiles.cluster.ceph;
in {
  options.profiles.cluster.ceph.monInitialHosts = with lib; mkOption {
    type = with types; listOf attrs;
    default = [];
    inherit (options.profiles.cluster.node.peers) example;
  };

  config.services.ceph.global.monInitialMembers = builtins.concatStringsSep "," (
    builtins.concatMap
      (h: h.config.services.ceph.mon.daemons)
      cfg.monInitialHosts
  );
}
