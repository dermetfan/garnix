{ config, pkgs, ... }:

{
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
