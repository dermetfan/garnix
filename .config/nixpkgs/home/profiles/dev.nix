{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dev;
in {
  options.profiles.dev = with lib; {
    enable     = mkEnableOption "developer programs";
    enableRust = mkEnableOption "Rust developer programs";
    enableJava = mkEnableOption "Java developer programs";
    enableWeb  = mkEnableOption "web developer programs";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      mercurial.enable = true;
      git      .enable = true;
      jq       .enable = true;

      geany.enable = config.xsession.enable;

      cargo.enable = cfg.enableRust;
    };

    home.packages = with pkgs;
      [ ripgrep
        ack
        nox
        nixos-shell
        pijul
        qemu
        dos2unix
      ] ++
      (lib.optional config.programs.tmux.enable tmuxp) ++
      lib.optionals stdenv.isLinux [
        loc
      ] ++
      lib.optionals config.xsession.enable [
        aqemu
        meld
        pgadmin
      ] ++
      lib.optionals cfg.enableRust [
        lldb
        rustracer
        rustracerd
      ] ++
      lib.optionals cfg.enableJava (
        [ openjdk
          gradle
        ] ++
        lib.optionals config.xsession.enable [
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
