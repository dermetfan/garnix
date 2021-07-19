{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.admin;
in {
  options.profiles.admin.enable = lib.mkEnableOption "sysadmin programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bashmount
      bandwhich
      binutils
      curl
      fd
      fdupes
      file
      fzy
      du-dust
      entr
      gptfdisk
      lrzip
      lsof
      ncdu
      ncid
      neofetch
      nix-prefetch-scripts
      nixops
      peco
      procs
      pv
      rsync
      sd
      sipcalc
      smartmontools
      socat
      wakelan
      wget
      gotty
      bottom
    ] ++ lib.optionals config.profiles.gui.enable [
      tigervnc
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
    ] ++ lib.optionals (config.profiles.gui.enable && stdenv.isLinux) [
      glxinfo
      gpa
      gparted
      filezilla
    ];

    programs = {
      bat.enable = true;
      jq.enable = true;
      nix-index.enable = true;
    };
  };
}
