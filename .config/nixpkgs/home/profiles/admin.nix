{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.admin;
in {
  options.profiles.admin.enable = lib.mkEnableOption "sysadmin programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bashmount
      binutils
      curl
      fdupes
      file
      fzy
      gptfdisk
      lrzip
      lsof
      ncdu
      ncid
      neofetch
      nix-index
      nix-prefetch-scripts
      nixops
      peco
      pv
      rsync
      sipcalc
      smartmontools
      socat
      wakelan
      wget
      gotty
    ] ++ lib.optionals stdenv.isLinux [
      diffoscope
      ftop
      hdparm
      libsysfs
      nethogs
      ngrep
      parted
      pciutils
      psmisc
      progress
      sshfsFuse
    ] ++ lib.optionals (config.xsession.enable && stdenv.isLinux) [
      glxinfo
      gpa
      gparted
      filezilla
    ];

    programs.bat.enable = true;
  };
}
