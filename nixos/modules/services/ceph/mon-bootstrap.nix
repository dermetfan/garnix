{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.mon.mkfs;
in {
  options.services.ceph.mon.mkfs = lib.mkEnableOption "preparation of each Ceph MON's state directory" // {
    default = true;
  };

  config.bootstrap.secrets = lib.mkIf cfg (
    builtins.listToAttrs (
      map (id: lib.nameValuePair "ceph-mon-${id}/bootstrap.keyring" {
        file = "secrets/services/ceph.client.admin.keyring";
        path = "/var/lib/${config.systemd.services."ceph-mon-${id}".serviceConfig.StateDirectory}/keyring";
        mode = "0400";
        owner = config.users.users.ceph.uid;
        group = config.users.groups.ceph.gid;
      }) config.services.ceph.mon.daemons
    )
  );

  config.systemd.services = lib.mkIf cfg (
    builtins.listToAttrs (
      map (id: lib.nameValuePair "ceph-mon-${id}" {
        path = with pkgs; [ ceph ];
        preStart = ''
          set -euxo pipefail

          function cleanup {
              rm -f /tmp/{monmap,keyring}
          }
          trap cleanup EXIT

          # Probe for some file other than the keyring that indicates
          # whether the directory has already been initialized.
          if [[ -f "$STATE_DIRECTORY"/kv_backend ]]; then
              exit
          fi

          # Move the bootstrap keyring out of the way.
          mv "$STATE_DIRECTORY"/keyring /tmp/keyring

          ceph mon getmap -o /tmp/monmap --keyring /tmp/keyring

          ceph-mon --mkfs -i ${lib.escapeShellArg id} --monmap /tmp/monmap --keyring /tmp/keyring

          ceph auth get mon. -o "$STATE_DIRECTORY"/keyring --keyring /tmp/keyring
          chmod 0400 "$STATE_DIRECTORY"/keyring
        '';
      }) config.services.ceph.mon.daemons
    )
  );
}
