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
      file
      fzy
      gptfdisk
      httpie
      lrzip
      lsof
      ncdu
      ncid
      neofetch
      nix-index
      nixops
      peco
      pv
      rsync
      sipcalc
      smartmontools
      socat
      wakelan
      wget
    ] ++ lib.optionals stdenv.isLinux [
      diffoscope
      ftop
      hdparm
      httping
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
    ];
  };
}
