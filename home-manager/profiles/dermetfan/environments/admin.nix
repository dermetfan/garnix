{ config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.admin.enable.default = false;

  config.home.packages = with pkgs; [
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
  ] ++ lib.optionals config.profiles.dermetfan.environments.gui.enable [
    tigervnc
    nix-query-tree-viewer
  ] ++ lib.optionals stdenv.isLinux [
    diffoscope
    ftop
    hdparm
    libsysfs
    mdcat
    nethogs
    ngrep
    parted
    pciutils
    psmisc
    progress
    sshfsFuse
    tty-share
    upterm
  ] ++ lib.optionals (config.profiles.dermetfan.environments.gui.enable && stdenv.isLinux) [
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
}
