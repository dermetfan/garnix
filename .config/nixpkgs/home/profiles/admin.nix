{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    bashmount
    binutils
    curl
    fdupes
    ftop
    fzy
    gptfdisk
    hdparm
    libsysfs
    lrzip
    lsof
    ncdu
    parted
    pciutils
    peco
    progress
    psmisc
    pv
    nethogs
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
