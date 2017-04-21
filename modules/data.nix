{ apmLevel ? 128
, config, pkgs }:

{
  fileSystems."/data" = {
    device = "data";
    fsType = "zfs";
  };

  powerManagement.powerUpCommands = (if apmLevel != null then
    (let
      dev = if config.fileSystems."/data".encrypted.enable then
        config.fileSystems."/data".encrypted.blkDev
      else
        config.fileSystems."/data".device;
    in ''
      ${pkgs.hdparm}/bin/hdparm -B ${builtins.toString apmLevel} ${dev}
    '') else "");

  security.pam.mount = {
    enable = true;
    extraVolumes = [
      ''<volume pgrp="${config.users.groups.users.name}" mountpoint="/data/%(USER)" path="data/%(USER)" fstype="zfs" />''
    ];
  };

  environment.interactiveShellInit = ''
    export PATH="$PATH:/data/`whoami`/bin"
  '';

  services.znapzend.enable = true;
}
