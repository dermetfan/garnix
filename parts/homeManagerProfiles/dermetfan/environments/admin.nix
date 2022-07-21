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
    entr
    lsof
    ncdu
    nix-diff
    nix-du
    nix-output-monitor
    nix-prefetch-scripts
    nix-universal-prefetch
    procs
    pv
    rsync
    socat
    bottom
    ijq
  ] ++ lib.optionals config.profiles.dermetfan.environments.gui.enable [
    tigervnc
    nix-query-tree-viewer
  ] ++ lib.optionals stdenv.isLinux [
    diffoscope
    ftop
    sysfsutils
    mdcat
    pciutils
    psmisc
    progress
    sshfs-fuse
    tty-share
  ] ++ lib.optionals (config.profiles.dermetfan.environments.gui.enable && stdenv.isLinux) [
    gpa
  ];

  programs = {
    bat.enable = true;
    jq.enable = true;
    nix-index.enable = true;
    ripgrep.enable = true;
    skim.enable = true;
    direnv.enable = true;
  };
}
