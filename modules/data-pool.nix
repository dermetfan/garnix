{ config, lib, ... }:

let
  cfg = config.config.dataPool;

  nonEmptyStr = with lib.types; addCheck str (x: x != "");
in {
  options.config.dataPool = with lib; {
    enable = mkEnableOption "a dedicated zpool";

    name = mkOption {
      type = nonEmptyStr;
      default = "data";
      description = "The name of the zpool.";
    };

    mountPoint = mkOption {
      type = nonEmptyStr;
      default = "/data";
    };

    userFileSystems = mkEnableOption "a file system for each user at <option>config.dataPool.mountPoint</option><literal>/&lt;user&gt;</literal>";

    bin = mkOption {
      type = types.bool;
      default = true;
      description = "Wether to add <option>config.dataPool.mountPoint</option>[<literal>/&lt;user&gt;</literal>]<filename>/bin</filename> to <code>PATH</code>.";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = {
      "${cfg.mountPoint}" = {
        device = cfg.name;
        label = cfg.name;
        fsType = "zfs";
        encrypted.label = cfg.name;
      };
    };

    security.pam.mount = lib.mkIf cfg.userFileSystems {
      enable = true;
      extraVolumes = [
        ''<volume pgrp="${config.users.groups.users.name}" mountpoint="${cfg.mountPoint}/%(USER)" path="${cfg.name}/%(USER)" fstype="zfs" />''
      ];
    };

    environment.interactiveShellInit = lib.optionalString cfg.bin ''
      [ `id -u` = ${toString config.ids.uids.root} ] && export PATH="$PATH:${cfg.mountPoint}/bin"
    '' + lib.optionalString (cfg.bin && cfg.userFileSystems) ''
      export PATH="$PATH:${cfg.mountPoint}/`whoami`/bin"
    '';

    services = {
      hydra.logo = "${cfg.mountPoint}/hydra/logo.png";
      postgresql.dataDir = "${cfg.mountPoint}/postgresql";
      minecraft-server.dataDir = "${cfg.mountPoint}/minecraft";
    };
  };
}
