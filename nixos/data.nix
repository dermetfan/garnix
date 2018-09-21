{ config, lib, ... }:

let
  cfg = config.config.data;

  nonEmptyStr = with lib.types; addCheck str (x: x != "");
in {
  options.config.data = with lib; {
    enable = mkEnableOption "a dedicated file system";

    mountPoint = mkOption {
      type = nonEmptyStr;
      default = "/data";
    };

    userFileSystems = mkEnableOption "a file system for each user at <option>config.data.mountPoint</option><literal>/&lt;user&gt;</literal>";

    bin = mkOption {
      type = types.bool;
      default = true;
      description = "Wether to add <option>config.data.mountPoint</option>[<literal>/&lt;user&gt;</literal>]<filename>/bin</filename> to <code>PATH</code>.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.mount = lib.mkIf cfg.userFileSystems {
      enable = true;
      extraVolumes = let
        fileSystem = config.fileSystems."${cfg.mountPoint}";
      in [
        ''<volume pgrp="${config.users.groups.users.name}" mountpoint="${cfg.mountPoint}/%(USER)" path="${fileSystem.device}/%(USER)" fstype="${fileSystem.fsType}"/>''
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
      syncthing.dataDir = "${cfg.mountPoint}/syncthing";
    };
  };
}
