{ config, pkgs, ... }:

{
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-kpu";
  };

  security.pam.mount = {
    enable = true;
    extraVolumes = [
      ''<volume pgrp="users" mountpoint="/data/%(USER)" path="data/%(USER)" fstype="zfs" />''
    ];
  };

  environment.interactiveShellInit = ''
    export PATH="$PATH:/data/`whoami`/bin"
  '';
}
