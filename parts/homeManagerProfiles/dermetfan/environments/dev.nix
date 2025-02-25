{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.environments.dev;
in {
  options.profiles.dermetfan.environments.dev = with lib; {
    enable.default = false;
    enableNative = mkEnableOption "native development programs";
    enableRust = mkEnableOption "Rust development programs";
    enableWeb = mkEnableOption "web development programs";
  };

  config = {
    programs = {
      man = {
        enable = true;
        generateCaches = true;
      };

      mercurial.enable = true;
      git.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      skim.enable = true;
      direnv.enable = true;

      geany.enable = config.profiles.dermetfan.environments.gui.enable;

      cargo.enable = cfg.enableRust;
    };

    home.packages = with pkgs;
      [
        man-pages
        ack
        grex
        comma
        nox
        nixos-shell
        pijul
        qemu
        dos2unix
        hyperfine
        entr
        watchexec
        jnv
        jd-diff-patch
        yq
        zig-shell-completions
      ] ++
      lib.optionals stdenv.isLinux [
        tty-share
        upterm
        mdcat
      ] ++
      lib.optionals config.profiles.dermetfan.environments.gui.enable [
        # aqemu
        meld
        # pgadmin
        sqlitebrowser
      ] ++
      lib.optionals cfg.enableNative [
        lldb
        valgrind
        qcachegrind
      ] ++
      lib.optionals cfg.enableWeb (
        [ httpie curlie ] ++
        lib.optionals pkgs.stdenv.isLinux [
          httping
        ]
      )
    ;
  };
}
