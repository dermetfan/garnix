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

    programs.git = {
      enable = true;
      userName = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";
      aliases = {
        st = "status -s";
        lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium HEAD";
        co = "checkout";
        ci = "commit";
        spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
      };
      extraConfig = {
        status.submoduleSummary = true;
        diff.submodule = "log";
      };
    };

    home.packages = with pkgs;
      [ ack
        jq
        nox
        qemu
      ] ++
      lib.optionals stdenv.isLinux [
        loc
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
