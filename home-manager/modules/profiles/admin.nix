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
      nix-diff
      nix-du
      nix-output-monitor
      nix-prefetch-scripts
      nix-universal-prefetch
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
      ijq
    ] ++ lib.optionals config.profiles.gui.enable [
      tigervnc
      nix-query-tree-viewer
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
      tty-share
      upterm
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
      ripgrep.enable = true;
      skim.enable = true;
    };
  };
}
