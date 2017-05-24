{ config, pkgs, lib }:

let
  settings = {
    dedicatedPool = false;
    multiUser = false;
  } // config.passthru.settings.data or {};
in {
  fileSystems = lib.mkIf settings.dedicatedPool {
    "/data" = {
      device = "data";
      fsType = "zfs";
      encrypted.label = "data";
    };
  };

  security.pam.mount = lib.mkIf settings.multiUser {
    enable = true;
    extraVolumes = [
      ''<volume pgrp="${config.users.groups.users.name}" mountpoint="/data/%(USER)" path="data/%(USER)" fstype="zfs" />''
    ];
  };

  environment.interactiveShellInit = ''
    [ `${pkgs.coreutils}/bin/id -u` = 0 ] && export PATH="$PATH:/data/bin"
  '' + lib.optionalString settings.multiUser ''
    export PATH="$PATH:/data/`whoami`/bin"
  '';
}
