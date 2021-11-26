{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.mon.mkfs;
in {
  options.services.ceph.mon.mkfs = lib.mkEnableOption "preparation of each Ceph MON's state directory";

  config.systemd.services = lib.mkIf cfg (
    builtins.listToAttrs (map (id: let
      serviceName = "ceph-mon-${id}";
      stateDirectory = lib.escapeShellArg "/var/lib/ceph/mon/ceph-${id}";
    in lib.nameValuePair serviceName {
      path = with pkgs; [ ceph ];
      preStart = ''
        set -euxo pipefail

        # Probe for some file other than the keyring that indicates
        # whether the directory has already been initialized.
        if [[ -f ${stateDirectory}/kv_backend ]]; then
            exit
        fi

        mkdir -p ${stateDirectory}

        function cleanup {
            rm -f /tmp/{monmap,keyring}
        }
        trap cleanup EXIT

        # Move the keyring away so that the state directory
        # is empty and `ceph-mon --mkfs` does not complain.
        # It will recreate the keyring in the same location.
        mv ${stateDirectory}/keyring /tmp/keyring

        ceph mon -n mon. getmap --keyring /tmp/keyring -o /tmp/monmap

        ceph-mon --mkfs -i ${lib.escapeShellArg id} --monmap /tmp/monmap --keyring /tmp/keyring
      '';
    }) config.services.ceph.mon.daemons)
  );
}
