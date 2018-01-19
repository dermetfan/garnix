{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.dev;
in {
  options.config.profiles.dev = with lib; {
    enable = mkEnableOption "developer programs";
    enableRust = mkEnableOption "Rust developer programs";
    enableJava = mkEnableOption "Java developer programs";
  };

  config = lib.mkIf cfg.enable {
    config.programs = {
      geany.enable = config.xsession.enable;
      mercurial.enable = true;
      cargo.enable = cfg.enableRust;
    };

    home.packages = with pkgs;
      [ ack
        jq
        loc
        nox
        qemu
      ] ++
      lib.optionals config.xsession.enable [
        aqemu
        meld
        pgadmin
      ] ++
      lib.optionals cfg.enableRust [
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
      );
  };
}
