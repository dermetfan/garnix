{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dev;
in {
  options.profiles.dev = with lib; {
    enable = mkEnableOption "development programs";
    enableNative = mkEnableOption "native development programs";
    enableRust = mkEnableOption "Rust development programs";
    enableJava = mkEnableOption "Java development programs";
    enableWeb = mkEnableOption "web development programs";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      mercurial.enable = true;
      git.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      skim.enable = true;

      geany.enable = config.profiles.gui.enable;

      cargo.enable = cfg.enableRust;
    };

    home.packages = with pkgs;
      [ ack
        grex
        nox
        nixos-shell
        pijul
        qemu
        dos2unix
        tokei
        hyperfine
        entr
        ijq
        yq
      ] ++
      lib.optionals stdenv.isLinux [
        loc
        tty-share
        upterm
        mdcat
      ] ++
      lib.optionals config.profiles.gui.enable [
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
      lib.optionals cfg.enableRust [
        # XXX re-enable once no longer marked as broken
        # rustracer
        # rustracerd
      ] ++
      lib.optionals cfg.enableJava (
        [ openjdk
          gradle
        ] ++
        lib.optionals config.profiles.gui.enable [
          android-studio
          jetbrains.idea-community
          visualvm
        ]
      ) ++
      lib.optionals cfg.enableWeb (
        [ httpie ] ++
        lib.optionals pkgs.stdenv.isLinux [
          httping
        ]
      )
    ;
  };
}
