{ config, lib, ... }:

let
  cfg = config.profiles.ceph;
in {
  options.profiles.ceph.enable = lib.mkEnableOption "Ceph settings" // {
    default = config.services.ceph.enable;
  };

  config = lib.mkIf cfg.enable {
    age.secrets =
      builtins.listToAttrs (map
        (id: let
          inherit (config.systemd.services."ceph-mon-${id}") serviceConfig;
        in lib.nameValuePair "ceph.mon.${id}.keyring" {
          file = ../../../secrets/services/ceph.mon..keyring.age;
          path = "/var/lib/${serviceConfig.StateDirectory}/keyring";
          owner = serviceConfig.User;
        })
        config.services.ceph.mon.daemons
      ) //
      builtins.listToAttrs (map
        (id: let
          inherit (config.systemd.services."ceph-mgr-${id}") serviceConfig;
        in lib.nameValuePair "ceph.mgr.${id}.keyring" {
          file = ../../../secrets/services/ceph.mgr.${id}.keyring.age;
          path = "/var/lib/${serviceConfig.StateDirectory}/keyring";
          owner = serviceConfig.User;
        })
        config.services.ceph.mgr.daemons
      ) //
      builtins.listToAttrs (map
        (id: let
          inherit (config.systemd.services."ceph-mds-${id}") serviceConfig;
        in lib.nameValuePair "ceph.mds.${id}.keyring" {
          file = ../../../secrets/services/ceph.mds.${id}.keyring.age;
          path = "/var/lib/${serviceConfig.StateDirectory}/keyring";
          owner = serviceConfig.User;
        })
        config.services.ceph.mds.daemons
      );
  };
}
