{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    binutils
    fdupes
    ftop
    fzy
    gptfdisk
    hdparm
    libsysfs
    lrzip
    ncdu
    parted
    peco
    progress
    psmisc
    pv
    rsync
    smartmontools
    sshfsFuse
    wakelan
    wget
  ] ++ (lib.optionals config.xsession.enable [
    gpa
    gparted
  ]);
}
