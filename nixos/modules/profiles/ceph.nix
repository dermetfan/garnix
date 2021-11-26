{ config, lib, ... }:

let
  cfg = config.profiles.ceph;
in {
  options.profiles.ceph.enable = lib.mkEnableOption "Ceph settings" // {
    default = config.services.ceph.enable;
  };

  config = lib.mkIf cfg.enable {
    age.secrets = builtins.listToAttrs (map
      (id: let
        inherit (config.systemd.services."ceph-mon-${id}") serviceConfig;
      in lib.nameValuePair "ceph.mon.${id}.keyring" {
        file = ../../../secrets/services/ceph.mon..keyring.age;
        path = "/var/lib/${serviceConfig.StateDirectory}/keyring";
        owner = serviceConfig.User;
      })
      config.services.ceph.mon.daemons
    );
  };
}
