_:

{ config, lib, pkgs, ... }:

let
  cfg = config.boot.initrd.services.zfs-rollback;

  escapeZfsComponentForSystemd =
    lib.replaceStrings
    [ "."     "-"     " "     ]
    [ "\\x2e" "\\x2d" "\\x20" ];

  snapshots = lib.forEach cfg.snapshots (raw: let
    # https://docs.oracle.com/cd/E26505_01/html/E37384/gbcpt.html
    # Space works in OpenZFS but is undocumented.
    component = "(([[:alnum:]]|[_:.-]|[[:space:]])+)";
    matches = lib.match "${component}/${component}@${component}" raw;
  in {
    pool = lib.elemAt matches 0;
    dataset = lib.elemAt matches 2;
    snapshot = lib.elemAt matches 4;
  });
in {
  options.boot.initrd.services.zfs-rollback = {
    enable = lib.mkEnableOption "rollback of zfs datasets";

    snapshots = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Fully qualified snapshots (<pool>/<dataset>@<snapshot>) to roll back to.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.services.zfs-rollback = {
      wantedBy = [ "initrd.target" ];
      after = lib.forEach snapshots ({ pool, ... }: "zfs-import-${escapeZfsComponentForSystemd pool}.service");
      before = [ "sysroot.mount" ];

      path = [ config.boot.zfs.package ];
      script = lib.concatMapStrings ({ pool, dataset, snapshot }: ''
        zfs rollback -r ${lib.escapeShellArg (pool + "/" + dataset + "@" + snapshot)}
      '') snapshots;

      serviceConfig.Type = "oneshot";
      unitConfig.DefaultDependencies = "no";
    };
  };
}
