{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.admin;
in {
  options.config.profiles.admin.enable = lib.mkEnableOption "sysadmin programs";

  config = lib.mkIf cfg.enable {
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
      neofetch
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
    ] ++ lib.optionals config.xsession.enable [
      gpa
      gparted
    ];
  };
}
