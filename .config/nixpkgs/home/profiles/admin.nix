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
      diffoscope
      fdupes
      file
      ftop
      fzy
      gptfdisk
      hdparm
      httpie
      httping
      libsysfs
      lrzip
      lsof
      ncdu
      ncid
      neofetch
      ngrep
      nix-index
      parted
      pciutils
      peco
      progress
      psmisc
      pv
      nethogs
      rsync
      smartmontools
      socat
      sshfsFuse
      wakelan
      wget
    ] ++ lib.optionals config.xsession.enable [
      glxinfo
      gpa
      gparted
    ];
  };
}
