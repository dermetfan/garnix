_:

{ config, lib, ... }:

let
  cfg = config.profiles.iog;
in {
  options.profiles.iog.enable = lib.mkEnableOption "IOG";

  config = lib.mkIf cfg.enable {
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
    ];
  };
}

