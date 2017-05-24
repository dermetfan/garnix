{ config, pkgs }:

{
  fileSystems."/data" = {
    device = "data";
    fsType = "zfs";
    encrypted.label = "data";
  };

  security.pam.mount = {
    enable = true;
    extraVolumes = [
      ''<volume pgrp="${config.users.groups.users.name}" mountpoint="/data/%(USER)" path="data/%(USER)" fstype="zfs" />''
    ];
  };

  environment.interactiveShellInit = ''
    export PATH="$PATH:/data/`whoami`/bin"
  '';
}
