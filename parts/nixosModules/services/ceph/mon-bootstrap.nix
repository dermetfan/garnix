{ self, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.mon.mkfs;
in {
  options.services.ceph.mon.mkfs = lib.mkEnableOption "preparation of each Ceph MON's state directory" // {
    default = true;
  };

  config.deployment.keys = lib.mkIf cfg (
    builtins.listToAttrs (
      map (id: lib.nameValuePair "ceph-mon-${id}-bootstrap.keyring" {
        keyCommand = [
          "rage"
          "--decrypt"
          "--identity"
          "secrets/deployer_ssh_ed25519_key"
          "${self}/secrets/services/ceph.client.admin.keyring.age"
        ];
        destDir = "/var/lib/${config.systemd.services."ceph-mon-${id}".serviceConfig.StateDirectory}";
        name = "keyring";
        permissions = "0400";
        user = config.users.users.ceph.name;
        group = config.users.groups.ceph.name;
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
