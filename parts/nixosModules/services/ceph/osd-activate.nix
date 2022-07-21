_:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.osd.activate;
in {
  options.services.ceph.osd.activate = with lib; mkOption {
    type = with types; attrsOf str;
    default = {};
    description = ''
      Map from ID to UUID of OSDs to activate before start.
      If you don't know your OSDs' UUIDs (AKA OSD FSIDs),
      look in <filename>/var/lib/ceph/osd/$cluster-$id/fsid</filename>.
    '';
  };

  config.systemd.services = lib.mapAttrs' (id: fsid: (let
    serviceName = "ceph-osd-${id}";
    service = config.systemd.services.${serviceName};
  in lib.nameValuePair
    "${serviceName}-activate"
    rec {
      wantedBy = [ "${serviceName}.service" ];
      before = wantedBy;
      path = with pkgs; [ ceph lvm2 cryptsetup util-linux ];
      script = ''
        ceph-volume lvm activate --no-systemd "$@"
      '';
      scriptArgs = lib.concatMapStringsSep " " lib.escapeShellArg [
        id fsid
      ];
      serviceConfig = {
        Type = "oneshot";
        inherit (service.serviceConfig) PrivateDevices;
      };
      unitConfig.ConditionPathExists = "!${service.unitConfig.ConditionPathExists}";
    }
  )) cfg;
}
